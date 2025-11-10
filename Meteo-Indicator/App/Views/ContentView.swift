//
//  ContentView.swift
//  Meteo-Indicator
//
//  Created by Dylan COUTO DE OLIVEIRA on 06/09/2025.
//

import Combine
import CoreLocation
import SwiftUI

struct ContentView: View {

    @StateObject private var weatherViewModel = WeatherViewModel()
    @State private var weatherText: Double = 0
    @State private var currentWeatherCode: Int? = nil
    @State private var weatherForecasts: [WeatherForecastModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let weatherIconProvider = WeatherIconProvider()

    private var currentWeatherIcon: WeatherIconData {
        weatherIconProvider.data(for: currentWeatherCode ?? -1)
    }

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                WeatherTemperaturePrediction(
                    weatherConditionImage: .sunCloud
                )

                VStack(spacing: 8) {

                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    } else {
                        Text(
                            weatherText.isNaN
                                ? "--" : String(format: "%.1f°C", weatherText)
                        )
                        .bold()
                        .foregroundStyle(Color(.black))
                        .shadow(radius: 10)
                        .font(.system(size: 30, weight: .bold))
                        .fontWidth(.init(10))
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .top
            )

            WeatherForecastListView(weatherForecasts)
        }
        .ignoresSafeArea()
        .task {
            await loadWeatherData()
        }
        .onReceive(
            Timer.publish(every: 300, on: .main, in: .common).autoconnect()
        ) { _ in
            Task {
                await loadWeatherData()
            }
        }
    }

    private func loadWeatherData() async {
        isLoading = true
        errorMessage = nil

        weatherText = await weatherViewModel.getCurrentWeather()
        currentWeatherCode = await weatherViewModel.getCurrentWeatherCode()

        if weatherViewModel.weather == nil {
            errorMessage =
                weatherViewModel.errorMessage ?? "Erreur de chargement"
            isLoading = false
            return
        }

        weatherForecasts = weatherViewModel.createWeatherForecastData()

        isLoading = false
    }
}

#Preview {
    ContentView()
}
