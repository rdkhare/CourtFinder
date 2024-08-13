//
//  HomePageView.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }

            LocateCourtsView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Locate Courts")
                }

            FavoriteCourtsView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorite Courts")
                }

            GroupsView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Groups")
                }
        }
        .accentColor(.blue) // Optional: Change the selected tab color
    }
}
