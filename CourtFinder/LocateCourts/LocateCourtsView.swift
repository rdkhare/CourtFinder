//
//  LocateCourtsView.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI
import GoogleMaps
import CoreLocation

struct LocateCourtsView: View {
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var courtsManager: CourtsManager
    @State private var isMapView = true
    @State private var isTransitioning = false
    @State private var mapSearchText = ""
    @State private var selectedPlaceIDForMap: String? = nil
    @State private var isRefreshing = false
    @State private var isButtonPanelExpanded = false // State for tracking if button panel is expanded
    
    private var mapSearchResults: [Court] {
        if mapSearchText.isEmpty {
            return []
        }
        return courtsManager.courts.filter {
            $0.name.localizedCaseInsensitiveContains(mapSearchText) ||
            $0.formatted_address.localizedCaseInsensitiveContains(mapSearchText)
        }.sorted { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Handle location authorization status first
                if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                    VStack {
                        Image(systemName: "location.slash.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Location access is required to find nearby courts")
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .padding()
                    }
                } else if let location = locationManager.location {
                    // Keep both views alive if location is available
                    // Use ZStack to layer them and opacity/hit testing to toggle
                    ZStack {
                        GoogleMapView(
                            coordinate: location.coordinate,
                            courts: courtsManager.courts,
                            selectedPlaceID: $selectedPlaceIDForMap
                        )
                        .opacity(isMapView ? 1 : 0) // Show map if isMapView is true
                        .allowsHitTesting(isMapView) // Make map interactable only when visible

                        ListView(courts: courtsManager.courts)
                            .opacity(isMapView ? 0 : 1) // Show list if isMapView is false
                            .allowsHitTesting(!isMapView) // Make list interactable only when visible
                    }
                    .animation(.easeInOut(duration: 0.3), value: isMapView) // Apply animation to the ZStack containing map/list
                    
                    // Collapsible Floating Button Panel - Positioned in a consistent place for both views
                    GeometryReader { geometry in
                        VStack(alignment: .trailing) {
                            // Position buttons at different heights based on which view is active
                            HStack {
                                Spacer()
                                
                                // Floating button panel
                                VStack(spacing: 12) {
                                    // Toggle Button (always visible)
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            isButtonPanelExpanded.toggle()
                                        }
                                    }) {
                                        Image(systemName: isButtonPanelExpanded ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.black)
                                            .frame(width: 50, height: 50)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    }
                                    
                                    // Action Buttons (visible only when expanded)
                                    if isButtonPanelExpanded {
                                        // View toggle button
                                        Button(action: {
                                            guard !isTransitioning else { return }
                                            isTransitioning = true
                                            
                                            withAnimation {
                                                isMapView.toggle()
                                            }
                                            
                                            // Reset transition flag after animation completes
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                isTransitioning = false
                                            }
                                        }) {
                                            Image(systemName: isMapView ? "list.bullet" : "map")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.black)
                                                .frame(width: 50, height: 50)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                        }
                                        .disabled(isTransitioning)
                                        .transition(.scale.combined(with: .opacity))
                                        
                                        // Refresh button
                                        Button(action: {
                                            refreshCourts()
                                        }) {
                                            Group {
                                                if isRefreshing {
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle())
                                                } else {
                                                    Image(systemName: "arrow.clockwise")
                                                        .font(.system(size: 16, weight: .bold))
                                                }
                                            }
                                            .foregroundColor(.black)
                                            .frame(width: 50, height: 50)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                        }
                                        .disabled(isRefreshing)
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            // Use different padding for each view to ensure proper alignment
                            .padding(.top, isMapView ? 20 : 70)
                            // Apply animation to ensure smooth transition
                            .animation(.easeInOut(duration: 0.3), value: isMapView)
                            
                            Spacer()
                        }
                        .frame(width: geometry.size.width)
                    }
                } else {
                    // Show progress view while waiting for location
                    ProgressView("Getting your location...")
                }
            }
            // Apply searchable conditionally ONLY when map is visible
            .if(isMapView) { view in
                view.searchable(text: $mapSearchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Courts on Map") {
                    ForEach(mapSearchResults) { court in
                        Button {
                            self.selectedPlaceIDForMap = court.place_id
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(court.name).bold()
                                Text(court.formatted_address).font(.caption)
                                if let distance = court.distance {
                                    Text(String(format: "%.2f mi", distance)).font(.caption).foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Locate Courts")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                courtsManager.fetchCourtsIfNeeded(location: location)
            }
        }
    }
    
    // Function to refresh courts
    private func refreshCourts() {
        guard let location = locationManager.location, !isRefreshing else { return }
        
        // Set refreshing state
        isRefreshing = true
        
        // Force fetch courts
        Task {
            courtsManager.refreshCourts(location: location)
            
            // Add a small delay to ensure refresh feels meaningful
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            // Update UI on main thread
            await MainActor.run {
                isRefreshing = false
            }
        }
    }
}

// Helper extension for conditional modifiers
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}