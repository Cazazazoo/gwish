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
}
