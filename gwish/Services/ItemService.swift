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

    func fetchItems(fromWishlist wishlistID: String, completion: @escaping (Result<[Item], Error>) -> Void) {
        firestore.fetchSubdocuments(from: "wishlists", parentId: wishlistID, subcollection: "items", as: Item.self, completion: completion)
    }
    
    func updateItem(inWishlist wishlistID: String, itemID: String, item: Item, completion: @escaping (Result<Void, Error>) -> Void) {
        firestore.updateSubdocument(in: "wishlists", parentId: wishlistID, subcollection: "items", documentId: itemID, with: item, completion: completion)
    }
    
    func deleteItem(fromWishlist wishlistID: String, itemID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        firestore.deleteSubdocument(from: "wishlists", parentId: wishlistID, subcollection: "items", documentId: itemID, completion: completion)
    }
}
