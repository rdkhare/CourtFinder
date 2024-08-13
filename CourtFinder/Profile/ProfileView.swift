//
//  ProfileView.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    if viewModel.isUpdatingImage {
                        ProgressView()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                    } else if let imageUrl = viewModel.photoURL {
                        CachedImageView(url: imageUrl)
                            .id(imageUrl.absoluteString) // Force reload when URL changes
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                    }

                    Text(viewModel.displayName)
                        .font(.title)
                        .bold()
                }
                .padding(.top, 30)

                VStack(alignment: .leading, spacing: 20) {
                    Section(header: Text("Groups").font(.headline)) {
                        if viewModel.groups.isEmpty {
                            Text("No groups joined yet.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.groups, id: \.self) { group in
                                Text(group)
                            }
                        }
                    }

                    Section(header: Text("Games Checked In").font(.headline)) {
                        if viewModel.gamesCheckedIn.isEmpty {
                            Text("No games checked in yet.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.gamesCheckedIn, id: \.self) { game in
                                Text(game)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarItems(trailing: Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gear")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            })
            .sheet(isPresented: $showSettings) {
                ProfileSettingsView(viewModel: viewModel)
            }
            .alert(item: $viewModel.errorMessage) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct CachedImageView: View {
    let url: URL

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else {
                ProgressView()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        ImageCache.shared.load(url: url) { image in
            self.image = image
        }
    }
}


