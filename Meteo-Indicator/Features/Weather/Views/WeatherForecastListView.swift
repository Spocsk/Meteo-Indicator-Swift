//
//  FourDaysWeatherForecastListView.swift
//  Meteo-Indicator
//
//  Created by Dylan on 25/10/2025.
//

import SwiftUI

struct WeatherForecastData {
    var mockedData: [WeatherForecastModel] = []

    init(_ mockedData: [WeatherForecastModel] = []) {
        if mockedData.isEmpty {
            self.mockedData = [
                WeatherForecastModel(
                    nDay: 1,
                    weatherTemperatures: [],
                    maxWeatherTemperature: 12.0,
                    weatherCode: 80
                ),
                WeatherForecastModel(
                    nDay: 2,
                    weatherTemperatures: [],
                    maxWeatherTemperature: 11.0,
                    weatherCode: 3
                ),
                WeatherForecastModel(
                    nDay: 3,
                    weatherTemperatures: [],
                    maxWeatherTemperature: 11.5,
                    weatherCode: 0
                ),
            ]
        } else {
            self.mockedData = mockedData
        }
    }
}

struct WeatherForecastListView: View {

    var weatherForecasts: [WeatherForecastModel] = []
    private let weatherIconProvider = WeatherIconProvider()

    init(_ weatherForecasts: [WeatherForecastModel] = []) {
        self.weatherForecasts = weatherForecasts
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prévisions")
                .font(.title2).bold()
                .padding(.horizontal)
                .fontWidth(.init(10))

            List {
                ForEach(self.weatherForecasts, id: \.self) { forecast in
                    let iconData = icon(for: forecast)

                    HStack(spacing: 16) {
                        Image(systemName: iconData.icon)
                            .font(.system(size: 28, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("J+\(forecast.nDay)")
                                .font(.headline)
                            Text(iconData.weatherDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(
                            "\(forecast.maxWeatherTemperature, specifier: "%.1f") °C"
                        )
                        .font(.headline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.thinMaterial)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 1)
                    .listRowInsets(
                        EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(0)
    }

    private func icon(for forecast: WeatherForecastModel) -> WeatherIconData {
        weatherIconProvider.data(for: forecast.weatherCode ?? -1)
    }

}

#Preview {
    WeatherForecastListView(WeatherForecastData().mockedData)
}
