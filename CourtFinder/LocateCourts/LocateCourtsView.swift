//
//  LocateCourtsView.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI
import GoogleMaps

struct LocateCourtsView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var courts: [Court] = []

    var body: some View {
        ZStack {
            if let location = locationManager.location {
                GoogleMapView(coordinate: location.coordinate, courts: courts)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        PlacesService().fetchNearbyCourts(location: location) { courts in
                            self.courts = courts
                        }
                    }
            } else {
                Text("Fetching location...")
                    .foregroundColor(.gray)
            }
        }
    }
}




