//
//  User.swift
//  gwish
//
//  Created by Connie Zhu on 2/28/25.
//

import FirebaseFirestore

struct User: Codable {
    @DocumentID var userID: String?
    var username: String
    var createdDate: Timestamp
}
