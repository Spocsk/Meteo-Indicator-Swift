//
//  WeatherIconProvider.swift
//  Meteo-Indicator
//
//  Created by Dylan on 01/10/2025.
//

import Foundation
import SwiftUI

struct WeatherIconData: Codable {
    let icon: String
    let wmoCode: Int
    let weatherDescription: String

    enum CodingKeys: String, CodingKey {
        case icon
        case wmoCode = "wmo_code"
        case weatherDescription
    }

}

struct WeatherIconProvider {

    /// Returns the WeatherIconData for the given WMO weather code.
    /// Covers all known WMO codes and returns a default value otherwise.
    func data(for weatherCode: Int) -> WeatherIconData {
        switch weatherCode {
        case 0:
            return WeatherIconData(
                icon: "sun.max.fill",
                wmoCode: weatherCode,
                weatherDescription: "Ciel clair"
            )
        case 1...2:
            return WeatherIconData(
                icon: "cloud.sun.fill",
                wmoCode: weatherCode,
                weatherDescription: "Peu nuageux à variable"
            )
        case 3:
            return WeatherIconData(
                icon: "cloud.fill",
                wmoCode: weatherCode,
                weatherDescription: "Couvert"
            )
        case 45...48:
            return WeatherIconData(
                icon: "cloud.fog.fill",
                wmoCode: weatherCode,
                weatherDescription: "Brouillard"
            )
        case 51...57:
            return WeatherIconData(
                icon: "cloud.drizzle.fill",
                wmoCode: weatherCode,
                weatherDescription: "Bruine"
            )
        case 61...67:
            return WeatherIconData(
                icon: "cloud.rain.fill",
                wmoCode: weatherCode,
                weatherDescription: "Pluie ou pluie verglaçante"
            )
        case 71...77:
            return WeatherIconData(
                icon: "cloud.snow.fill",
                wmoCode: weatherCode,
                weatherDescription: "Neige"
            )
        case 80...82:
            return WeatherIconData(
                icon: "cloud.heavyrain.fill",
                wmoCode: weatherCode,
                weatherDescription: "Averses"
            )
        case 85...86:
            return WeatherIconData(
                icon: "cloud.snow.fill",
                wmoCode: weatherCode,
                weatherDescription: "Averses de neige"
            )
        case 95...99:
            return WeatherIconData(
                icon: "cloud.bolt.rain.fill",
                wmoCode: weatherCode,
                weatherDescription: "Orage"
            )
        default:
            return WeatherIconData(
                icon: "cloud.fill",
                wmoCode: weatherCode,
                weatherDescription: "Nuageux"
            )
        }
    }
}
