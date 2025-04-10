//
//  MapView.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/28/24.
//

import SwiftUI
import GoogleMaps

struct GoogleMapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D // Initial center (user location)
    var courts: [Court]
    @Binding var selectedPlaceID: String? // Binding for selected place_id
    
    final class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView
        var hasInitializedCamera = false
        var markerToSelectAfterAnimation: GMSMarker? // Store the marker object
        
        init(_ parent: GoogleMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let court = marker.userData as? Court {
//                print("Tapped marker for court: \(court.name)")
                // You could potentially update the targetCoordinate here too if needed
                // Or show a custom info window / navigate to detail view
            }
            // Return false to allow default behavior (show info window) AND keep marker selected
            // Return true to override default behavior
            return false
        }
        
        func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
            return nil
        }
        
        // Delegate method called when map finishes moving/becomes idle
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//            print("Map idle at position: \(position.target)")
            // Check if we need to select a marker after an animation
            if let marker = markerToSelectAfterAnimation {
                print("Map idle. Selecting stored marker: \(marker.title ?? "nil")")
                mapView.selectedMarker = marker
                // Reset the flag
                markerToSelectAfterAnimation = nil 
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 14.0)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        // Animate to target coordinate if it changes and is not nil
        // Remove the animation logic based on targetCoordinate
        /*
        if let target = targetCoordinate, context.coordinator.parent.targetCoordinate != nil {
             print("Animating map to target coordinate: \(target)")
             mapView.animate(with: GMSCameraUpdate.setTarget(target, zoom: 15.0)) // Adjust zoom as needed
             
             DispatchQueue.main.async {
                 context.coordinator.parent.targetCoordinate = nil
                 print("Reset target coordinate binding")
             }
        }
        */
        
        // Only set initial camera position once if no target is selected initially
        // Check if selectedPlaceID is nil to avoid overriding the animation
        if !context.coordinator.hasInitializedCamera && selectedPlaceID == nil {
            let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 14.0)
            mapView.camera = camera
            context.coordinator.hasInitializedCamera = true
        }

        // Clear and update markers
        DispatchQueue.main.async {
            mapView.clear()
            
            for court in courts {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: court.geometry.location.lat, longitude: court.geometry.location.lng)
                marker.title = court.name
                if let distance = court.distance {
                    marker.snippet = "\(court.formatted_address), \(String(format: "%.2f", distance)) miles"
                } else {
                    marker.snippet = court.formatted_address
                }
                marker.userData = court // Store the court object
                
                // Check if this is the marker corresponding to the selected place ID
                if court.place_id == context.coordinator.parent.selectedPlaceID {
                    // Store the marker reference in the coordinator instead of selecting immediately
                    context.coordinator.markerToSelectAfterAnimation = marker 
                }
                
                // Customize marker appearance
                marker.icon = GMSMarker.markerImage(with: .red)
                marker.appearAnimation = .pop
                
                // Set the map last to trigger the animation
                marker.map = mapView
            }
            
            // If a selection ID was processed in this update cycle, animate the camera
            // Note: markerToSelectAfterAnimation is set *inside* the loop if a match was found
            if let markerToAnimateTo = context.coordinator.markerToSelectAfterAnimation {
                 print("Found marker to animate to (ID: \(context.coordinator.parent.selectedPlaceID ?? "nil")). Animating camera.")
                 
                 // Animate camera
                 mapView.animate(with: GMSCameraUpdate.setTarget(markerToAnimateTo.position, zoom: 15.0))
                 
                 // Select the marker to show the info window
                 mapView.selectedMarker = markerToAnimateTo
            }
        }
    }
}
