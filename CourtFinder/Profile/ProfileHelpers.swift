//
//  ProfileHelpers.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/18/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileHelpers {
    static let shared = ProfileHelpers()

    func fetchUserProfile(userId: String, completion: @escaping (User?, [String: Any]?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                completion(Auth.auth().currentUser, document.data())
            } else {
                completion(nil, nil)
            }
        }
    }

    func updateFirestoreUserProfile(userId: String, photoURL: URL?, displayName: String?, username: String?, completion: @escaping (Bool) -> Void) {
        var data: [String: Any] = [:]
        if let photoURL = photoURL {
            data["photoURL"] = photoURL.absoluteString
        }
        if let displayName = displayName {
            data["displayName"] = displayName
        }
        if let username = username {
            data["username"] = username
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(data, merge: true) { error in
            completion(error == nil)
        }
    }

    func uploadProfilePicture(image: UIImage, userId: String, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference().child("profile_pictures/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if error != nil {
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                completion(url)
            }
        }
    }
}

