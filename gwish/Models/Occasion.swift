//
//  Occasion.swift
//  gwish
//
//  Created by Connie Zhu on 3/1/25.
//

import FirebaseFirestore

struct Occasion: Codable {
    @DocumentID var occasionID: String?
    var name: String
}
