//
//  Status.swift
//  gwish
//
//  Created by Connie Zhu on 3/1/25.
//

import FirebaseFirestore

struct Status: Codable {
    @DocumentID var statusID: String?
    var name: String
}
