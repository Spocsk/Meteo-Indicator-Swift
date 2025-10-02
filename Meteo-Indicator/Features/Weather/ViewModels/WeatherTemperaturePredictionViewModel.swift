//
//  WeatherTemperaturePredictionViewModel.swift
//  Meteo-Indicator
//
//  Created by Dylan on 01/10/2025.
//

import SwiftUI

struct WeatherTemperaturePredictionViewModel {

    func getWeatherImageFromWeatherCode(_ code: Int) -> ImageResource {
        switch code {
        case 0...57:
            return .sunny
        case 58...67:
            return .rain
        case 68...77:
            return .snow
        case 80...82:
            return .rain
        case 85...86:
            return .snow
        case 95...99:
            return .thunder
        default:
            return .cloud
        }
    }
}

