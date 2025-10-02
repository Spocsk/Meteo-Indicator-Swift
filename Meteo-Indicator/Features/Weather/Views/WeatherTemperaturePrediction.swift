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
        Image(self.weatherConditionImage)
            .resizable()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    WeatherTemperaturePrediction()
}
