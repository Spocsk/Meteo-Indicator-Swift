//
//  WeatherViewModel.swift
//  Meteo-Indicator
//
//  Created by Dylan COUTO DE OLIVEIRA on 11/09/2025.
//

import Combine
import CoreLocation
import Foundation

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var weatherCode: Int?
    @Published var errorMessage: String?

    private let httpClient: HTTPClient
    private let locationManager: LocationManager

    init(httpClient: HTTPClient? = nil) {
        self.httpClient = httpClient ?? URLSessionHTTPClient()
        self.locationManager = LocationManager()
    }

    /// Fetches the current weather code aligned with the current hour (Europe/Paris)
    func getCurrentWeatherCode() async -> Int? {
        if weather != nil {
            return getWeatherCodeFromDateTime(Date())
        }

        await locationManager.getCurrentLocation()

        guard let coords = locationManager.currentLocation else {
            errorMessage = "Impossible d'obtenir la localisation"
            return nil
        }

        await getWeatherData(
            latitude: coords.latitude,
            longitude: coords.longitude
        )

        if let code = self.weatherCode {
            return code
        }

        return getWeatherCodeFromDateTime(Date())
    }

    func getCurrentWeather() async -> Double {

        if let temp = weather?.current.temperature2m {
            return temp
        }

        await locationManager.getCurrentLocation()

        guard let coords = locationManager.currentLocation else {
            errorMessage = "Impossible d'obtenir la localisation"
            return 0
        }

        await getWeatherData(
            latitude: coords.latitude,
            longitude: coords.longitude
        )

        print(
            "Weather: \(String(describing: self.weather?.current.temperature2m))"
        )

        guard let temperature = self.weather?.current.temperature2m else {
            return 0
        }

        return temperature
    }

    func getWeatherCodeFromDateTime(_ date: Date = Date()) -> Int? {
        let currentKey = roundDateTimeMinuteToZero(date)
        guard let hourly = weather?.hourly, !hourly.time.isEmpty else {
            return nil
        }

        for (index, time) in hourly.time.enumerated() {
            if time == currentKey {
                if index < hourly.weatherCode.count {
                    return hourly.weatherCode[index]
                }
            }
        }
        return nil
    }

    func createWeatherForecastData(
        _ date: Date = Date(),
        _ numberOfDays: Int = 5
    ) -> [WeatherForecastModel] {
        var data: [WeatherForecastModel] = []

        guard self.weather?.hourly != nil else {
            print("Warning: No weather data available for forecast")
            return []
        }

        for day in 1..<numberOfDays {
            let dayDate =
                Calendar.current.date(byAdding: .day, value: day, to: date)
                ?? date
            let temperatures: [Double] = self.getWeatherTemperatureFromDateTime(
                dayDate
            )

            // Skip this day if we don't have any temperature readings
            guard !temperatures.isEmpty else {
                print("Warning: No temperature data for day +\(day)")
                continue
            }

            let maxTemperature: Double =
                self.getMaxTemperatureFromWeatherTemperatureArray(temperatures)

            data.append(
                WeatherForecastModel(
                    nDay: day,
                    weatherTemperatures: temperatures,
                    maxWeatherTemperature: maxTemperature,
                    weatherCode: self.getWeatherCodeFromDateTime(dayDate)
                )
            )
        }

        return data
    }

    /// Get weather data from specific location
    private func getWeatherData(latitude: Double, longitude: Double) async {
        guard let url = makeWeatherURL(latitude: latitude, longitude: longitude)
        else {
            self.weather = nil
            self.errorMessage = "URL invalide"
            return
        }
        do {
            let response: WeatherResponse = try await httpClient.get(url: url)
            self.weather = response

            let currentDateTime = self.roundDateToHour(Date())
            let currentKey = self.roundDateTimeMinuteToZero(currentDateTime)
            let hourly = response.hourly
            if let index = hourly.time.firstIndex(of: currentKey),
                index < hourly.weatherCode.count
            {
                self.weatherCode = hourly.weatherCode[index]
            } else {
                self.weatherCode = nil
            }

            self.errorMessage = nil
        } catch {
            self.weather = nil
            self.errorMessage =
                "Échec du chargement: \(error.localizedDescription)"
            print("Error: \(String(describing: error))")
        }
    }

    private func makeWeatherURL(latitude: Double, longitude: Double) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.open-meteo.com"
        components.path = "/v1/forecast"
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "hourly", value: "temperature_2m,weather_code"),
            URLQueryItem(name: "forecast_days", value: "4"),
            URLQueryItem(name: "timezone", value: "Europe/Paris"),
            URLQueryItem(name: "current", value: "temperature_2m"),
            URLQueryItem(name: "models", value: "meteofrance_seamless"),
        ]
        return components.url
    }

    private func roundDateTimeMinuteToZero(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        // Format type : 2025-09-20T12:00 (Europe/Paris)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Paris")
        dateFormatter.locale = Locale(identifier: "fr_FR_POSIX")
        let formattedDateString: String = dateFormatter.string(from: date)
        let dateStringWithoutMinutes: String = formattedDateString.components(
            separatedBy: ":"
        )[0]
        return dateStringWithoutMinutes + ":00"
    }

    private func roundDateToHour(_ date: Date) -> Date {
        Calendar.current.date(bySetting: .minute, value: 0, of: date) ?? date
    }

    private func getWeatherTemperatureFromDateTime(_ date: Date = Date())
        -> [Double]
    {
        // Ensure we have hourly data
        guard let hourly = self.weather?.hourly else { return [] }

        // Build a yyyy-MM-dd key in Europe/Paris to match the prefix of Open‑Meteo `hourly.time`
        let dayKey = extractDayFromDateTime(date)  // e.g. "2025-11-04"

        var temperatures: [Double] = []

        for (index, time) in hourly.time.enumerated()
        where time.hasPrefix(dayKey) {
            if index < hourly.temperature2m.count,
                let t = hourly.temperature2m[index]
            {
                temperatures.append(t)
            }
        }

        return temperatures
    }

    private func extractDayFromDateTime(_ date: Date = Date()) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(identifier: "Europe/Paris")
        df.locale = Locale(identifier: "fr_FR_POSIX")
        return df.string(from: date)
    }

    private func getMaxTemperatureFromWeatherTemperatureArray(
        _ weatherTemperatureArray: [Double]
    ) -> Double {
        guard let maxTemperature = weatherTemperatureArray.max() else {
            print("Error: No temperature data. Cannot get max temperature.")
            return 0.0
        }
        return maxTemperature
    }

    private func getWeatherWithCurrentDateTime() async -> String {

        await locationManager.getCurrentLocation()

        guard let coords = locationManager.currentLocation else {
            return "Pas de localisation disponible"
        }

        await getWeatherData(
            latitude: coords.latitude,
            longitude: coords.longitude
        )

        let currentDateTime = roundDateToHour(Date())
        let currentKey = roundDateTimeMinuteToZero(currentDateTime)

        guard let hourly = weather?.hourly, !hourly.time.isEmpty else {
            return "No data"
        }

        for (index, time) in hourly.time.enumerated() {
            if time == currentKey {
                if index < hourly.temperature2m.count {
                    if let temperature = hourly.temperature2m[index] {
                        return formatTemperature(temperature)
                    } else {
                        return "No data"
                    }
                }
            }
        }

        return "No data"
    }

    private func formatTemperature(_ temperature: Double) -> String {
        String(format: "%.0f", round(temperature)) + "°C"
    }

}
