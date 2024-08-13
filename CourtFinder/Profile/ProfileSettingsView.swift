//
//  ProfileSettingsView.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI

struct ProfileSettingsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showEditNameView = false
    @State private var showEditUsernameView = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 20) {
                    Text("Settings")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 20)

                    VStack {
                        if viewModel.isUpdatingImage {
                            ProgressView()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                .shadow(radius: 5)
                        } else if let imageUrl = viewModel.photoURL {
                            CachedImageView(url: imageUrl)
                                .id(imageUrl.absoluteString) // Force reload when URL changes
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                .shadow(radius: 5)
                                .onTapGesture {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        viewModel.showImagePicker = true
                                    }
                                }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                .shadow(radius: 5)
                                .onTapGesture {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        viewModel.showImagePicker = true
                                    }
                                }
                        }
                    }
                    .padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Name")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(viewModel.displayName)
                                .font(.body)
                                .foregroundColor(.black)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showEditNameView = true
                        }

                        NavigationLink("", destination: EditNameView(viewModel: viewModel, newName: viewModel.displayName), isActive: $showEditNameView)
                            .hidden()

                        HStack {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(viewModel.username)
                                .font(.body)
                                .foregroundColor(.black)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showEditUsernameView = true
                        }

                        NavigationLink("", destination: EditUsernameView(viewModel: viewModel, newUsername: viewModel.username), isActive: $showEditUsernameView)
                            .hidden()
                    }
                    .padding(.horizontal, 20)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding()

                Button("Logout") {
                    viewModel.logout()
                }
                .padding()
                .foregroundColor(.red)
                
                Spacer()
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $viewModel.showImagePicker, onDismiss: {
                viewModel.loadImage()
                viewModel.showImagePicker = false // Resetting the state
            }) {
                ImagePicker(image: $viewModel.inputImage)
            }
        }
    }
}



