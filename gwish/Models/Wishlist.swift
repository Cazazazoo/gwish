//
//  Wishlist.swift
//  gwish
//
//  Created by Connie Zhu on 2/28/25.
//

import FirebaseFirestore

struct Wishlist: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var lastUpdated: Timestamp
    var userID: String
    // TODO: add profileID for making a wishlist for frined
    var creationDate: Timestamp
    // TODO: add public/private
    
    var items: [Item]? = []
    
    // If Needed: decoded into the names of the struct
//    enum CodingKeys: String, CodingKey {
//        case name = "item_name"      // Mapping "item_name" in Firestore to "name" in struct
//        case price = "item_price"    // Mapping "item_price" in Firestore to "price" in struct
//        case priority = "item_priority" // Mapping "item_priority" in Firestore to "priority" in struct
//    }
}
