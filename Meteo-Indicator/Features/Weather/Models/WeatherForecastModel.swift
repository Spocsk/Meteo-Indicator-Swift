//
//  WeatherForecastModel.swift
//  Meteo-Indicator
//
//  Created by Dylan on 05/11/2025.
//

struct WeatherForecastModel: Codable, Hashable {
    let nDay: Int
    let weatherTemperatures: [Double]
    let maxWeatherTemperature: Double
    let weatherCode: Int?
}
