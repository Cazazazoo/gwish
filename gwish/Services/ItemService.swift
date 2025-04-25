//
//  ItemService.swift
//  gwish
//
//  Created by Connie Zhu on 4/24/25.
//

import Foundation

final class ItemService {
    private let firestore = FirestoreService.shared

    func addItem(toWishlist wishlistID: String, item: Item, completion: @escaping (Result<Void, Error>) -> Void) {
        firestore.addSubdocument(to: "wishlists", parentId: wishlistID, subcollection: "items", data: item, completion: completion)
    }

    func fetchItems(forWishlist wishlistID: String, completion: @escaping (Result<[Item], Error>) -> Void) {
        firestore.fetchSubdocuments(from: "wishlists", parentId: wishlistID, subcollection: "items", as: Item.self, completion: completion)
    }
}
