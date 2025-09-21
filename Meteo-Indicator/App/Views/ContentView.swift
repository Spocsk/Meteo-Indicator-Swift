//
//  ContentView.swift
//  Meteo-Indicator
//
//  Created by Dylan COUTO DE OLIVEIRA on 06/09/2025.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var weatherViewModel = WeatherViewModel()
    @State private var weatherText: String = ""

    var body: some View {
        VStack {
            Text(weatherText)
        }
        .task {
            weatherText = await weatherViewModel.getWeatherWithCurrentDateTime()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
