//
//  WishlistService.swift
//  gwish
//
//  Created by Connie Zhu on 4/24/25.
//

import Foundation
import FirebaseFirestore

final class WishlistService {
    private let firestore = FirestoreService.shared

    func createWishlist(_ wishlist: Wishlist, completion: @escaping (Result<DocumentReference, Error>) -> Void) {
        firestore.addDocument(to: "wishlists", data: wishlist, completion: completion)
    }

    func fetchWishlists(forUser userID: String, completion: @escaping (Result<[Wishlist], Error>) -> Void) {
        firestore.fetchDocuments(from: "wishlists", as: Wishlist.self, whereField: "userID", isEqualTo: userID, completion: completion)
    }
    
    func updateWishlist(_ wishlist: Wishlist, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = wishlist.id else {
            completion(.failure(NSError(domain: "WishlistService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing wishlist ID"])))
            return
        }

        firestore.updateDocument(in: "wishlists", documentId: id, with: wishlist, completion: completion)
    }
    
    func deleteWishlist(_ wishlist: Wishlist, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = wishlist.id else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing wishlist ID"])))
            return
        }
        firestore.deleteDocument(from: "wishlists", documentId: id, completion: completion)
    }
}
