//
//  ListView.swift
//  CourtFinder
//
//  Created by Rajat Khare on 8/22/24.
//

import Foundation
import SwiftUI
import CoreLocation

struct ListView: View {
    @EnvironmentObject var courtsManager: CourtsManager
    var courts: [Court]
    @State private var localCourts: [Court] = []
    @State private var favoriteTogglingInProgress = false
    @State private var searchText = ""
    
    private var sortedCourts: [Court] {
        courts.sorted { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
    }
    
    private var filteredCourts: [Court] {
        if searchText.isEmpty {
            return sortedCourts
        } else {
            return sortedCourts.filter { court in
                court.name.localizedCaseInsensitiveContains(searchText) || 
                court.formatted_address.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search by name or address", text: $searchText)
                    .foregroundColor(.primary)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            if filteredCourts.isEmpty && !searchText.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No courts match your search")
                        .font(.headline)
                    Text("Try different keywords or clear the search")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredCourts) { court in
                    CourtRowView(court: court, favoriteTogglingInProgress: $favoriteTogglingInProgress)
                        .environmentObject(courtsManager)
                        .contentShape(Rectangle()) // Make the entire row tappable
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            localCourts = courtsManager.favoriteCourts
        }
        .onReceive(courtsManager.$favoriteCourts) { updatedCourts in
            localCourts = updatedCourts
        }
    }
}

// Extract CourtRowView to improve reusability and performance
struct CourtRowView: View {
    @EnvironmentObject var courtsManager: CourtsManager
    let court: Court
    @Binding var favoriteTogglingInProgress: Bool
    @State private var isLocalFavorite: Bool
    @State private var showMaxFavoritesAlert = false
    
    init(court: Court, favoriteTogglingInProgress: Binding<Bool>) {
        self.court = court
        self._favoriteTogglingInProgress = favoriteTogglingInProgress
        self._isLocalFavorite = State(initialValue: false)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(court.name)
                    .font(.headline)
                
                Text(court.formatted_address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    if let rating = court.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                        }
                    }
                    
                    if let totalRatings = court.user_ratings_total {
                        Text("(\(totalRatings) reviews)")
                            .foregroundColor(.gray)
                    }
                }
                
                if let distance = court.distance {
                    Text(String(format: "%.2f miles away", distance))
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if let isOpen = court.opening_hours?.open_now {
                    Text(isOpen ? "Open Now" : "Closed")
                        .font(.caption)
                        .foregroundColor(isOpen ? .green : .red)
                }
                
                // Show the first few types (excluding generic ones)
                let relevantTypes = court.types.filter { !["point_of_interest", "establishment"].contains($0) }
                if !relevantTypes.isEmpty {
                    HStack {
                        ForEach(relevantTypes.prefix(2), id: \.self) { type in
                            Text(type.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Favorite Button
            Button {
                // Prevent rapid multiple toggling
                guard !favoriteTogglingInProgress else { return }
                
                // Check if we're trying to add a new favorite and we're at the limit
                if !isLocalFavorite && courtsManager.isMaxFavoritesReached() {
                    showMaxFavoritesAlert = true
                    return
                }
                
                // Optimistic UI update
                isLocalFavorite.toggle()
                favoriteTogglingInProgress = true
                
                Task {
                    await courtsManager.toggleFavorite(court)
                    
                    // Release the lock after operation completes
                    DispatchQueue.main.async {
                        // Update local favorite state based on the actual state after the operation
                        isLocalFavorite = courtsManager.isCourtFavorited(court.place_id)
                        favoriteTogglingInProgress = false
                    }
                }
            } label: {
                Image(systemName: isLocalFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isLocalFavorite ? .red : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(favoriteTogglingInProgress)
            .alert("Maximum Favorites Reached", isPresented: $showMaxFavoritesAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You can have a maximum of \(CourtsManager.maxFavorites) favorite courts. Please remove some favorites before adding more.")
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            isLocalFavorite = courtsManager.isCourtFavorited(court.place_id)
        }
        // Update local state when court changes (e.g., from API)
        .onChange(of: court.isFavorite) { newValue in
            isLocalFavorite = courtsManager.isCourtFavorited(court.place_id)
        }
        // Update when the favorites list changes
        .onReceive(courtsManager.$favoriteCourts) { _ in
            isLocalFavorite = courtsManager.isCourtFavorited(court.place_id)
        }
    }
}
