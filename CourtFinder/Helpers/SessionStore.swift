//
//  SessionStore.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI
import FirebaseAuth

class SessionStore: ObservableObject {
    @Published var isUserLoggedIn: Bool = false

    init() {
        listen()
    }

    func listen() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                print("User is signed in as \(user.uid).")
                self.isUserLoggedIn = true
            } else {
                print("No user is signed in.")
                self.isUserLoggedIn = false
            }
        }
    }
}
