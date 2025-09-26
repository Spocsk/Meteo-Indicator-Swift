//
//  WeatherViewModel.swift
//  Meteo-Indicator
//
//  Created by Dylan COUTO DE OLIVEIRA on 11/09/2025.
//

import Combine
import Foundation

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var errorMessage: String?

    private let httpClient: HTTPClient
    private let weatherBaseUrl: String =
        "https://api.open-meteo.com/v1/forecast?latitude=48.84&longitude=1.55&hourly=temperature_2m"

    init(httpClient: HTTPClient? = nil) {
        self.httpClient = httpClient ?? URLSessionHTTPClient()
    }

    /// Get weather data from specific location
    private func getWeatherData() async {
        guard let url = URL(string: weatherBaseUrl) else {
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
    
    private func roundDateTimeMinuteToZero(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        // Format type : 2025-09-20T12:00
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.locale = Locale(identifier: "fr")
        let formattedDateString: String = dateFormatter.string(from: date)
        let dateStringWithoutMinutes: String = formattedDateString.components(separatedBy: ":")[0]
        return dateStringWithoutMinutes + ":00"
    }
    
    private func roundDateToHour(_ date: Date) -> Date {
        Calendar.current.date(bySetting: .minute, value: 0, of: date) ?? date
    }

    func getWeatherWithCurrentDateTime() async -> String {
        await getWeatherData()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "fr")
        // Format type : 2025-09-20T12:00
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"

        let today = Date()
        let currentDateTime: Date = roundDateToHour(today)
        let currentDateFormattedWithoutMinutes: String = roundDateTimeMinuteToZero(currentDateTime)

        if let hourly = weather?.hourly, !hourly.time.isEmpty {
            for (index, time) in hourly.time.enumerated() {
                if currentDateFormattedWithoutMinutes == time {
                    if let temperature = weather?.hourly.temperature2m[index] {
                        return "Temp : \(formatTemperature(temperature))"
                    }
                    return "Data found at \(time)"
                }
            }
        }
        return "No data"
    }
    
    private func formatTemperature(_ temperature: Double) -> String {
        String(format: "%.0f", round(temperature)) + "°C"
    }
}
