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
}
