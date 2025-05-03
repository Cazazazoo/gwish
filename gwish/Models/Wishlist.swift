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
    var creationDate: Timestamp
    var isPublic: Bool? // Optional for now
    // TODO: add profileID for making a wishlist for frined
    
    var items: [Item]? = []
}
