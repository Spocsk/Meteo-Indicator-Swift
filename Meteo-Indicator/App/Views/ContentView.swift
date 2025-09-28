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
    @State private var weatherText: String = ""

    var body: some View {
        VStack {
            Text(weatherText)
            if let coords = locationManager.currentLocation {
                Text("lat: \(coords.latitude), long: \(coords.longitude)")
            }
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
