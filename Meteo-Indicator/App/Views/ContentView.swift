//
//  ContentView.swift
//  Meteo-Indicator
//
//  Created by Dylan COUTO DE OLIVEIRA on 06/09/2025.
//

import CoreLocation
import SwiftUI

struct ContentView: View {

    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var weatherText: Double = 0

    var weatherTemperaturePredictionViewModel =
        WeatherTemperaturePredictionViewModel()

    var body: some View {
        VStack {
            WeatherTemperaturePrediction(
                weatherConditionImage:
                    weatherTemperaturePredictionViewModel
                    .getWeatherImageFromWeatherCode(
                        weatherViewModel.weatherCode ?? 0
                    )
            )
            Text(String(weatherText))
                .offset(y: -50)
                .bold()
                .shadow(radius: 10)
                .fontWidth(.init(10))
        }
        .task {
            weatherText = await weatherViewModel.getCurrentWeather()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
