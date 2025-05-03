//
//  ProfileService.swift
//  gwish
//
//  Created by Connie Zhu on 5/3/25.
//

import Foundation
import FirebaseFirestore

final class ProfileService {
    private let firestore = FirestoreService.shared
    private let collectionPath = "profiles"

    // MARK: - Create Profile
    func createProfile(for userId: String, profile: Profile, completion: @escaping (Result<Void, Error>) -> Void) {
        firestore.updateDocument(in: collectionPath, documentId: userId, with: profile, completion: completion)
    }

    // MARK: - Fetch Profile
    func fetchProfiles(for userId: String, completion: @escaping (Result<[Profile], Error>) -> Void) {
        Firestore.firestore()
            .collection(collectionPath)
            .whereField("userID", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                do {
                    let profiles = try snapshot?.documents.compactMap {
                        try $0.data(as: Profile.self)
                    } ?? []
                    completion(.success(profiles))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Update Profile
    func updateProfile(for profileId: String, profile: Profile, completion: @escaping (Result<Void, Error>) -> Void) {
        firestore.updateDocument(in: collectionPath, documentId: profileId, with: profile, completion: completion)
    }

    // MARK: - Connect Profiles
    func connectProfiles(userId: String, to connectedUserId: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        let ref = Firestore.firestore().collection(collectionPath).document(connectedUserId)
        Firestore.firestore().collection(collectionPath)
            .document(userId)
            .updateData(["connectedProfile": connectedUserId]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    /// Deletes a profile and handles cleanup (wishlists + connected profiles)
    func deleteProfile(profileId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()

        // Step 1: Delete wishlists tied to this profile
        db.collection("users").document(profileId).collection("wishlists").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let batch = db.batch()
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }

            // Step 2: Commit deletion of wishlists
            batch.commit { batchError in
                if let batchError = batchError {
                    completion(.failure(batchError))
                    return
                }

                // Step 3: Delete the profile document using FirestoreService
                FirestoreService.shared.deleteDocument(from: "users", documentId: profileId, completion: completion)
            }
        }
    }
}
