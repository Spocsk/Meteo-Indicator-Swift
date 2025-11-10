//
//  WeatherTemperaturePrediction.swift
//  Meteo-Indicator
//
//  Created by Dylan on 28/09/2025.
//

import Foundation
import SwiftUI

struct WeatherTemperaturePrediction: View {

    var weatherConditionImage: ImageResource = .sunCloud

    init(weatherConditionImage: ImageResource = .sunCloud) {
        self.weatherConditionImage = weatherConditionImage
    }

    var body: some View {
        ZStack() {
            Image(self.weatherConditionImage)
                .resizable()
                .scaledToFill()
        }
        .padding(0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

#Preview {
    WeatherTemperaturePrediction()
}
