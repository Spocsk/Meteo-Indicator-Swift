//
//  HTTPClient.swift
//  Meteo-Indicator
//
//  Created by Dylan COUTO DE OLIVEIRA on 11/09/2025.
//

import Foundation

// 1. Le protocole définit l’interface
protocol HTTPClient {
    func get<T: Decodable>(url: URL) async throws -> T
}

// 2. Implémentation concrète basée sur URLSession
struct URLSessionHTTPClient: HTTPClient {
    func get<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
