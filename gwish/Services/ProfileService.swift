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

    func createProfile(_ profile: Profile, completion: @escaping (Result<DocumentReference, Error>) -> Void) {
        firestore.addDocument(to: collectionPath, data: profile, completion: completion)
    }

    func fetchProfiles(for userId: String, completion: @escaping (Result<[Profile], Error>) -> Void) {
        firestore.fetchDocuments(from: collectionPath, as: Profile.self, whereField: "userID", isEqualTo: userId, completion: completion)
    }

    func updateProfile(_ profile: Profile, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = profile.id else {
            completion(.failure(NSError(domain: "ProfileService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing profile ID"])))
            return
        }

        firestore.updateDocument(in: collectionPath, documentId: id, with: profile, completion: completion)
    }

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
    func deleteProfile(_ profile: Profile, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        
        guard let profileId = profile.id else {
            completion(.failure(NSError(domain: "ProfileService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing profile ID"])))
            return
        }
        
        // Step 1: Query wishlists where user is the owner (allowed by rules)
        db.collection("wishlists")
            .whereField("userID", isEqualTo: profile.userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let batch = db.batch()
                
                // Step 2: Filter only wishlists with matching profileID
                let wishlistsToDelete = snapshot?.documents.filter {
                    $0.data()["profileID"] as? String == profileId
                } ?? []
                
                wishlistsToDelete.forEach { batch.deleteDocument($0.reference) }

                // Step 3: Commit wishlist deletions and then delete the profile
                batch.commit { batchError in
                    if let batchError = batchError {
                        completion(.failure(batchError))
                        return
                    }

                    FirestoreService.shared.deleteDocument(
                        from: self.collectionPath,
                        documentId: profileId,
                        completion: completion
                    )
                }
            }
    }
}
