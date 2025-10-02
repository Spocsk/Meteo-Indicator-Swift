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
            self.errorMessage = nil
        } catch {
            self.weather = nil
            self.errorMessage =
                "Échec du chargement: \(error.localizedDescription)"
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
            URLQueryItem(name: "hourly", value: "temperature_2m"),
        ]
        return components.url
    }

    private func roundDateTimeMinuteToZero(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        // Format type : 2025-09-20T12:00
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.locale = Locale(identifier: "fr")
        let formattedDateString: String = dateFormatter.string(from: date)
        let dateStringWithoutMinutes: String = formattedDateString.components(
            separatedBy: ":"
        )[0]
        return dateStringWithoutMinutes + ":00"
    }

    private func roundDateToHour(_ date: Date) -> Date {
        Calendar.current.date(bySetting: .minute, value: 0, of: date) ?? date
    }

    func getWeatherWithCurrentDateTime() async -> String {

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
                        self.weatherCode = hourly.weatherCode[index]
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
