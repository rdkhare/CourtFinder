//
//  CustomTabBar.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/28/24.
//

import SwiftUI

struct CustomTabBar: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(0)
                
                LocateCourtsView()
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Locate Courts")
                    }
                    .tag(1)
                
                FavoriteCourtsView()
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Favorite Courts")
                    }
                    .tag(2)
                
                GroupsView()
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Groups")
                    }
                    .tag(3)
            }
            .zIndex(0)
            
            // Add the background color for the tab bar
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .zIndex(1)
        }
    }
}

