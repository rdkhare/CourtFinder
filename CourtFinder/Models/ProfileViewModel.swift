//
//  ProfileViewModel.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var groups: [String] = []
    @Published var gamesCheckedIn: [String] = []

    private var db = Firestore.firestore()
    private var storage = Storage.storage()

    init() {
        fetchUserProfile()
    }

    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Error fetching user profile: \(error)")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                self.user = Auth.auth().currentUser
                self.groups = data?["groups"] as? [String] ?? []
                self.gamesCheckedIn = data?["gamesCheckedIn"] as? [String] ?? []
            } else {
                print("User profile does not exist")
            }
        }
    }

    func updateProfilePicture(image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = storage.reference().child("profile_pictures/\(uid).jpg")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading profile picture: \(error)")
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching profile picture URL: \(error)")
                    return
                }

                guard let url = url else { return }
                self.updateUserProfile(photoURL: url)
            }
        }
    }

    private func updateUserProfile(photoURL: URL) {
        guard let user = Auth.auth().currentUser else { return }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.photoURL = photoURL
        changeRequest.commitChanges { error in
            if let error = error {
                print("Error updating profile: \(error)")
                return
            }
            self.user = Auth.auth().currentUser
        }
    }
}
