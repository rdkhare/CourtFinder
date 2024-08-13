//
//  File.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/9/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)

                Text("Welcome to CourtFinder")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                Text("Find and locate sports courts near you")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)

                Spacer()

                Button(action: viewModel.handleGoogleSignIn) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.white)
                        Spacer()
                        Text("Sign in with Google")
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Sign In")
            .background(Color(.systemBackground).ignoresSafeArea())
            .fullScreenCover(isPresented: $viewModel.isLoginSuccessful) {
                HomePageView()
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Login Error"),
                    message: Text(viewModel.loginStatusMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
