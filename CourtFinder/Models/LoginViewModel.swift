//
//  LoginViewModel.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class LoginViewModel: ObservableObject {
    @Published var loginStatusMessage = ""
    @Published var isLoginSuccessful = false
    @Published var showAlert = false

    func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.loginStatusMessage = "Missing client ID"
            self.showAlert = true
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        guard let presentingViewController = getRootViewController() else {
            self.loginStatusMessage = "Unable to get the root view controller"
            self.showAlert = true
            return
        }
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
            if let error = error {
                self.loginStatusMessage = "Failed to log in with Google: \(error.localizedDescription)"
                self.showAlert = true
                return
            }

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                self.loginStatusMessage = "Failed to log in with Google: No authentication found"
                self.showAlert = true
                return
            }

            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    self.loginStatusMessage = "Failed to log in with Google: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }

                self.loginStatusMessage = ""
                self.isLoginSuccessful = true
            }
        }
    }
}
