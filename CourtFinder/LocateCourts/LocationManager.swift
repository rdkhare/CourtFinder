//
//  LocationManager.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/28/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    private var hasInitialLocation = false
    private var isUpdatingLocation = false
    private let locationQueue = DispatchQueue(label: "com.courtfinder.location", qos: .userInitiated)

    override init() {
        if #available(iOS 14.0, *) {
            self.authorizationStatus = locationManager.authorizationStatus
        } else {
            self.authorizationStatus = CLLocationManager.authorizationStatus()
        }
        super.init()
        locationQueue.async {
            self.setupLocationManager()
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // Reduced accuracy for better performance
        locationManager.distanceFilter = 50 // Only update if moved 50 meters
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
        
        if CLLocationManager.locationServicesEnabled() {
            DispatchQueue.main.async {
                self.locationManager.requestWhenInUseAuthorization()
                self.startUpdatingLocation()
            }
        } else {
            print("⚠️ Location services are disabled")
        }
    }
    
    private func startUpdatingLocation() {
        guard !isUpdatingLocation else { return }
        isUpdatingLocation = true
        locationManager.startUpdatingLocation()
    }
    
    private func stopUpdatingLocation() {
        isUpdatingLocation = false
        locationManager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if #available(iOS 14.0, *) {
                self.authorizationStatus = manager.authorizationStatus
            } else {
                self.authorizationStatus = CLLocationManager.authorizationStatus()
            }
            
            switch self.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startUpdatingLocation()
            case .denied, .restricted:
                self.stopUpdatingLocation()
                print("⚠️ Location access denied")
            case .notDetermined:
                print("ℹ️ Location access not determined")
            @unknown default:
                print("⚠️ Unknown location authorization status")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              location.horizontalAccuracy <= 100 else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.hasInitialLocation || (self.location?.distance(from: location) ?? 0) > 50 {
                self.location = location
                self.hasInitialLocation = true
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("❌ Location access denied")
            case .network:
                print("❌ Network error occurred")
            default:
                print("❌ Location update failed: \(error.localizedDescription)")
            }
        } else {
            print("❌ Location update failed: \(error.localizedDescription)")
        }
    }
}



