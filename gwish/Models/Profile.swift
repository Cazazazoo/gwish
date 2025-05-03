//
//  Profile.swift
//  gwish
//
//  Created by Connie Zhu on 5/3/25.
//

import FirebaseFirestore

struct Profile: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var lastUpdated: Timestamp
    var creationDate: Timestamp
    var userID: String

    /// A reference to the connected profile (friend/user)
    var connectedProfileID: String? // Document Reference later?

    var hobbies: [String]?
    var interests: [String]?

    /// Optional descriptor of how this profile relates to the current user (e.g., "friend", "partner", etc.)
    var relationshipToUser: String?
}

struct ProfileDraft: Identifiable {
    let id: String
    var name: String
    var relationshipToUser: String
    var hobbies: String
    var interests: String
    var connectedProfileID: String

    // no userID stored
    init(profile: Profile) {
        self.id = profile.id ?? UUID().uuidString
        self.name = profile.name
        self.relationshipToUser = profile.relationshipToUser ?? ""
        self.hobbies = profile.hobbies?.joined(separator: ", ") ?? ""
        self.interests = profile.interests?.joined(separator: ", ") ?? ""
        self.connectedProfileID = profile.connectedProfileID ?? ""
    }

    init() {
        self.id = UUID().uuidString
        self.name = ""
        self.relationshipToUser = ""
        self.hobbies = ""
        self.interests = ""
        self.connectedProfileID = ""
    }

    func toProfile(userID: String) -> Profile {
        Profile(
            id: nil,
            name: name,
            lastUpdated: Timestamp(date: Date()),
            creationDate: Timestamp(date: Date()),
            userID: userID,
            connectedProfileID: connectedProfileID.isEmpty ? nil : connectedProfileID,
            hobbies: parseCommaList(hobbies),
            interests: parseCommaList(interests),
            relationshipToUser: relationshipToUser
        )
    }

    private func parseCommaList(_ input: String) -> [String]? {
        let trimmed = input
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        return trimmed.isEmpty ? nil : trimmed
    }
}
