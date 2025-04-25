//
//  Category.swift
//  gwish
//
//  Created by Connie Zhu on 3/1/25.
//

import FirebaseFirestore

struct Category: Codable {
    @DocumentID var categoryID: String?
    var name: String
}
