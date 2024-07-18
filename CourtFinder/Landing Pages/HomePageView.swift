//
//  HomePageView.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                NavigationLink(destination: ProfileView()) {
                    Text("Profile")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)

                NavigationLink(destination: LocateCourtsView()) {
                    Text("Locate Courts")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)

                NavigationLink(destination: FavoriteCourtsView()) {
                    Text("Favorite Courts")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)

                NavigationLink(destination: GroupsView()) {
                    Text("Groups")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}
