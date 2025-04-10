//
//  FavoriteCourtsView.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI

struct FavoriteCourtsView: View {
    @EnvironmentObject var courtsManager: CourtsManager
    
    var body: some View {
        NavigationView { // Add NavigationView for title
            Group { // Use Group to conditionally show content
                if courtsManager.favoriteCourts.isEmpty {
                    VStack {
                        Image(systemName: "heart.slash.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .padding(.bottom)
                        Text("No Favorite Courts Yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Add courts from the 'Locate Courts' tab.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    // Filter and display only favorite courts
                    ListView(courts: courtsManager.favoriteCourts)
                }
            }
            .navigationTitle("Favorite Courts") // Set the navigation title
        }
    }
}
