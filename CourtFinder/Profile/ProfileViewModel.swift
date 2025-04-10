//
//  ProfileViewModel.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI
import FirebaseAuth

struct ProfileError: Identifiable {
    var id = UUID()
    var message: String
}


class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var displayName: String = ""
    @Published var photoURL: URL?
    @Published var username: String = ""
    @Published var groups: [String] = []
    @Published var gamesCheckedIn: [String] = []
    @Published var showImagePicker = false
    @Published var inputImage: UIImage?
    @Published var isUpdatingImage = false
    @Published var errorMessage: ProfileError?

    init() {
        fetchUserProfile()
    }

    func fetchUserProfile() {
        print("Fetching user profile...")
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user logged in.")
            return
        }

        ProfileHelpers.shared.fetchUserProfile(userId: uid) { user, data in
            if let data = data {
                self.user = user
                self.displayName = data["displayName"] as? String ?? ""
                self.username = data["username"] as? String ?? self.generateUsernameFromEmail()
                if let photoURLString = data["photoURL"] as? String {
                    self.photoURL = URL(string: photoURLString)
                }
                self.groups = data["groups"] as? [String] ?? []
                self.gamesCheckedIn = data["gamesCheckedIn"] as? [String] ?? []
//                print("User profile fetched successfully.")
            } else {
                self.createUserProfile(uid: uid)
            }
        }
    }

    private func createUserProfile(uid: String) {
        guard let currentUser = Auth.auth().currentUser else { return }

        let displayName = currentUser.displayName ?? "New User"
        let photoURL = currentUser.photoURL?.absoluteString ?? ""
        let username = self.generateUsernameFromEmail()

        ProfileHelpers.shared.updateFirestoreUserProfile(userId: uid, photoURL: URL(string: photoURL), displayName: displayName, username: username) { success in
            if success {
                self.user = currentUser
                self.displayName = displayName
                self.photoURL = URL(string: photoURL)
                self.username = username
                self.groups = []
                self.gamesCheckedIn = []
                print("User profile created successfully.")
            } else {
                print("Error creating user profile.")
            }
        }
    }

    private func generateUsernameFromEmail() -> String {
        guard let email = Auth.auth().currentUser?.email else { return "" }
        return email.components(separatedBy: "@").first ?? ""
    }

    func updateProfilePicture(image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Update the local state immediately
        let temporaryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().uuidString).jpg")
        try? image.jpegData(compressionQuality: 0.8)?.write(to: temporaryURL)
        self.photoURL = temporaryURL
        self.isUpdatingImage = true
        self.errorMessage = nil

        // Perform the Firestore update in the background
        ProfileHelpers.shared.uploadProfilePicture(image: image, userId: uid) { url in
            DispatchQueue.main.async {
                guard let url = url else {
                    self.errorMessage = ProfileError(message: "Failed to upload profile picture.")
                    self.isUpdatingImage = false
                    return
                }
                self.updateUserProfile(photoURL: url)
            }
        }
    }

    private func updateUserProfile(photoURL: URL? = nil, displayName: String? = nil, username: String? = nil) {
        guard let user = Auth.auth().currentUser else { return }
        let changeRequest = user.createProfileChangeRequest()
        if let photoURL = photoURL {
            changeRequest.photoURL = photoURL
        }
        if let displayName = displayName {
            changeRequest.displayName = displayName
        }
        changeRequest.commitChanges { error in
            if let error = error {
                print("Error updating profile: \(error)")
                self.errorMessage = ProfileError(message: "Failed to update profile information.")
                self.isUpdatingImage = false
                return
            }
            self.user = Auth.auth().currentUser
            if let photoURL = photoURL {
                self.photoURL = photoURL // Ensure photoURL is updated immediately
            }
            if let displayName = displayName {
                self.displayName = displayName
            }
            if let username = username {
                self.username = username
            }
            ProfileHelpers.shared.updateFirestoreUserProfile(userId: user.uid, photoURL: photoURL, displayName: displayName, username: username) { success in
                DispatchQueue.main.async {
                    self.isUpdatingImage = false
                    if success {
                        print("Firestore user profile updated successfully.")
                    } else {
                        self.errorMessage = ProfileError(message: "Failed to update Firestore profile.")
                    }
                }
            }
        }
    }

    func updateUserName(_ newName: String) {
        guard let user = Auth.auth().currentUser else { return }
        
        // Update the local state immediately
        self.displayName = newName
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newName
        changeRequest.commitChanges { error in
            if let error = error {
                print("Error updating display name: \(error)")
                return
            }
            self.user = Auth.auth().currentUser
            ProfileHelpers.shared.updateFirestoreUserProfile(userId: user.uid, photoURL: nil, displayName: newName, username: nil) { success in
                if success {
                    print("Firestore display name updated successfully.")
                }
            }
        }
    }

    func updateUserUsername(_ newUsername: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Update the local state immediately
        self.username = newUsername
        
        ProfileHelpers.shared.updateFirestoreUserProfile(userId: uid, photoURL: nil, displayName: nil, username: newUsername) { success in
            if success {
                print("Firestore username updated successfully.")
            } else {
                print("Error updating username.")
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.displayName = ""
            self.photoURL = nil
            self.groups = []
            self.gamesCheckedIn = []
            self.username = ""
            print("User signed out.")
        } catch let error as NSError {
            print("Error signing out: %@", error)
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        updateProfilePicture(image: inputImage)
    }
}
