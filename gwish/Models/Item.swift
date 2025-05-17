//
//  Item.swift
//  gwish
//
//  Created by Connie Zhu on 3/1/25.
//

import FirebaseFirestore

struct Item: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var price: Double?
    var priority: Priority?
    var url: [String]? // In viewmodel, change to url if anything
    var location: String?
    var creationDate: Timestamp
    // Include last updated for filter purposes?
    var complete: Bool
    // Collections below
    var category: DocumentReference? // Reference to Category
    var occasion: DocumentReference? // Reference to Occasion
    var status: DocumentReference? // Reference to Status
}

enum Priority: String, Codable, CaseIterable {
    case none, low, medium, high
}

struct ItemDraft: Identifiable {
    var id: String // required for `.sheet(item:)`
    var name = ""
    var price = ""
    var priority: Priority = .none
    var complete = false
    var location = ""
    // TODO: these item descriptors following my model
    var link = ""
    var category = ""
    var status = ""
    var occasion = ""

    init() {
        self.id = UUID().uuidString
    }

    /// Initializes a draft based on an existing `Item` from Firestore
    init(from item: Item) {
        self.id = item.id ?? UUID().uuidString
        self.name = item.name
        self.price = item.price != nil ? String(item.price!) : ""
        self.priority = item.priority ?? .none
        self.complete = item.complete
        self.location = item.location ?? ""
        self.link = item.url?.first ?? ""
        self.category = item.category?.documentID ?? ""
        self.occasion = item.occasion?.documentID ?? ""
        self.status = item.status?.documentID ?? ""
    }
    
    /// Converts the draft back into a full `Item` to save into Firestore
    /// Used when editing an existing item from a wishlist
    func toItem() -> Item {
        return Item(
            id: nil, // Let Firestore manage
            name: self.name,
            price: Double(self.price),
            priority: self.priority,
            url: self.link.isEmpty ? nil : [self.link],
            location: self.location.isEmpty ? nil : self.location,
            creationDate: Timestamp(date: Date()),
            complete: self.complete,
            category: self.category.isEmpty ? nil :
                Firestore.firestore().collection("categories").document(self.category),
            occasion: self.occasion.isEmpty ? nil :
                Firestore.firestore().collection("occasions").document(self.occasion),
            status: self.status.isEmpty ? nil :
                Firestore.firestore().collection("status").document(self.status)
        )
    }
}


