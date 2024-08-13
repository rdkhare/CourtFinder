//
//  MapView.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/28/24.
//

import SwiftUI
import GoogleMaps

struct GoogleMapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D
    var courts: [Court]

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 14.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 14.0)
        mapView.camera = camera

        // Clear existing markers
        mapView.clear()

        // Add markers for courts
        for court in courts {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: court.geometry.location.lat, longitude: court.geometry.location.lng)
            marker.title = court.name
            if let distance = court.distance {
                marker.snippet = "\(court.vicinity) - \(String(format: "%.2f", distance)) miles"
            } else {
                marker.snippet = court.vicinity
            }
            marker.map = mapView
        }
    }
}




