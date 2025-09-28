//
//  LocationManager.swift
//  Meteo-Indicator
//
//  Created by Dylan on 27/09/2025.
//

import CoreLocation
import SwiftUI
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject,
    CLLocationManagerDelegate
{
    private let locationManager = CLLocationManager()

    @Published private(set) var authorizationStatus: CLAuthorizationStatus =
        .notDetermined
    @Published private(set) var currentLocation: CLLocationCoordinate2D?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // L'état d'autorisation sera mis à jour automatiquement via le delegate
    }

    // MARK: - Public Methods

    func checkIfLocationServicesAreEnabled() -> Bool {
        CLLocationManager.locationServicesEnabled()
    }

    func requestUserAuthorization() {
        guard checkIfLocationServicesAreEnabled() else {
            errorMessage =
                "Les services de localisation ne sont pas activés sur cet appareil."
            return
        }
        locationManager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation() async {
        await handleAuthorizationStatusChange()
    }

    func resetError() {
        errorMessage = nil
    }

    // MARK: - Private Methods

    private func handleAuthorizationStatusChange() async {
        errorMessage = nil

        guard checkIfLocationServicesAreEnabled() else {
            errorMessage = "Les services de localisation ne sont pas activés."
            return
        }

        switch authorizationStatus {
        case .notDetermined:
            requestUserAuthorization()

        case .authorizedAlways, .authorizedWhenInUse:
            await fetchLocation()

        case .denied:
            errorMessage =
                "L'accès à la localisation a été refusé. Veuillez l'activer dans les Réglages."

        case .restricted:
            errorMessage =
                "L'accès à la localisation est restreint sur cet appareil."

        @unknown default:
            errorMessage = "Statut d'autorisation inconnu."
        }
    }

    private func fetchLocation() async {
        isLoading = true

        do {
            let coordinates = try await getLocationData()
            currentLocation = coordinates
            errorMessage = nil
            print("Location obtenue: \(coordinates)")
        } catch {
            handleLocationError(error)
        }

        isLoading = false
    }

    private func getLocationData(timeout: TimeInterval = 10) async throws
        -> CLLocationCoordinate2D
    {
        locationManager.startUpdatingLocation()
        let stream = CLLocationUpdate.liveUpdates()
        let deadline = Date().addingTimeInterval(timeout)

        defer {
            locationManager.stopUpdatingLocation()
        }

        for try await update in stream {
            if let location = update.location {
                return location.coordinate
            }

            if update.authorizationDenied {
                throw CLError(.denied)
            }

            if Date() > deadline {
                throw CLError(.locationUnknown)
            }
        }

        throw CLError(.locationUnknown)
    }

    private func handleLocationError(_ error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                errorMessage = "Accès à la localisation refusé."
            case .locationUnknown:
                errorMessage = "Impossible de déterminer votre position."
            case .network:
                errorMessage = "Erreur réseau lors de la localisation."
            default:
                errorMessage =
                    "Erreur de localisation: \(clError.localizedDescription)"
            }
        } else {
            errorMessage = "Erreur inattendue: \(error.localizedDescription)"
        }
        print("Erreur de localisation: \(error)")
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        Task {
            await handleAuthorizationStatusChange()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        handleLocationError(error)
        isLoading = false
    }
}
