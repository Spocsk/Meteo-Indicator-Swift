//
//  HTTPClient.swift
//  Meteo-Indicator
//
//  Created by Dylan COUTO DE OLIVEIRA on 11/09/2025.
//

import Foundation

class HTTPClient {
    func get<T: Decodable>(url: URL) async throws -> T {
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
