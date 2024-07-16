//
//  File.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/9/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoginMode = true
    @State private var loginStatusMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login").tag(true)
                        Text("Sign Up").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))

                    Button(action: handleAction) {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                            Spacer()
                        }
                        .background(Color.blue)
                        .cornerRadius(5)
                        .padding()
                    }

                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.systemBackground).ignoresSafeArea())
        }
    }

    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }

    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.loginStatusMessage = "Failed to log in: \(error.localizedDescription)"
                return
            }
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
        }
    }

    private func createNewAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.loginStatusMessage = "Failed to create account: \(error.localizedDescription)"
                return
            }
            self.loginStatusMessage = "Successfully created account for user: \(result?.user.uid ?? "")"
        }
    }
}
