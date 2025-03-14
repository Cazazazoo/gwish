//
//  Item.swift
//  gwish
//
//  Created by Connie Zhu on 3/1/25.
//

import FirebaseFirestore

struct Item: Codable {
    var name: String
    var price: Double?
    var priority: Priority?
    var url: [String]? // In viewmodel, change to url if anything
    var location: String?
    var creationDate: Timestamp
    // Collections below
    var category: DocumentReference? // Reference to Category
    var occasion: DocumentReference? // Reference to Occasion
    var status: DocumentReference? // Reference to Status
}

enum Priority: String, Codable {
    case low, medium, high
}

