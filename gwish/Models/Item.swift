//
//  Item.swift
//  gwish
//
//  Created by Connie Zhu on 3/1/25.
//

import FirebaseFirestore

struct Item: Codable {
    var name: String
    var price: Double
    var priority: Priority
    var url: URL? // TODO: make into array?
    var location: String
    var creationDate: Date
    // TODO: Need to decide if these will be subcollections/collection
    var category: DocumentReference? // Reference to Category
    var occasion: DocumentReference? // Reference to Occasion
    var status: DocumentReference? // Reference to Status
}

enum Priority: String, Codable {
    case low, medium, high
}

