//
//  LocationManager.swift
//  TheScene
//
//  Created by Ryder Klein on 11/21/23.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    @Published var userLocation: LocationStatus = .unprompted
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func updateLocation() {
        manager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            userLocation = .unprompted
        case .restricted:
            userLocation = .denied
        case .denied:
            userLocation = .denied
        case .authorizedWhenInUse:
            manager.requestLocation()
            userLocation = .loading
        case .authorizedAlways:
            manager.requestLocation()
            userLocation = .loading
        @unknown default:
            userLocation = .unprompted
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = .hasLocation(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Needs to be implemented or app crashes. May as well log the error.
        print("Error fetching location:")
        print(error)
    }
}

enum LocationStatus {
    case hasLocation(location: CLLocation)
    case loading
    case denied
    case unprompted
}
