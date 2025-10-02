//
//  WeatherModel.swift
//  Meteo-Indicator
//
//  Created by Dylan COUTO DE OLIVEIRA on 11/09/2025.
//

import Foundation

// MARK: - Root Weather Response
struct WeatherResponse: Codable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Double
    let hourlyUnits: HourlyUnits
    let hourly: Hourly
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case generationtimeMs = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case hourlyUnits = "hourly_units"
        case hourly
    }
}

// MARK: - Hourly Units
struct HourlyUnits: Codable {
    let time: String
    let temperature2m: String
    let weatherCode: String
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
    }
}

// MARK: - Hourly Data
struct Hourly: Codable {
    let time: [String]
    let temperature2m: [Double?]   // nullable car tu as des "null" dans ton JSON
    let weatherCode: [Int]
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
    }
}
