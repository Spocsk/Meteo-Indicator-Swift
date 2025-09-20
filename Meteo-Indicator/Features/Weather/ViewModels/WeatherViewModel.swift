//
//  WeatherViewModel.swift
//  Meteo-Indicator
//
//  Created by Dylan COUTO DE OLIVEIRA on 11/09/2025.
//

import Foundation
import Combine

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var errorMessage: String?

    private let httpClient: HTTPClient

    // Valeur par défaut pour éviter d'avoir à injecter le client à l'usage courant
    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }

    /// Récupère la météo et met à jour l'état observable
    func refresh() async {
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&hourly=temperature_2m") else {
            self.weather = nil
            self.errorMessage = "URL invalide"
            return
        }
        do {
            let response: WeatherResponse = try await httpClient.get(url: url)
            self.weather = response
            self.errorMessage = nil
        } catch {
            self.weather = nil
            self.errorMessage = "Échec du chargement: \(error.localizedDescription)"
        }
    }
}
