//
//  ProfileDetailView.swift
//  gwish
//
//  Created by Connie Zhu on 5/3/25.
//

import SwiftUI
import FirebaseFirestore

enum ProfileDetailMode {
    case add
    case edit(Profile)
}

struct ProfileDetailView: View {
    var mode: ProfileDetailMode
    var onSave: (ProfileDraft) -> Void
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var localDraft: ProfileDraft

    init(mode: ProfileDetailMode, draft: ProfileDraft, onSave: @escaping (ProfileDraft) -> Void, onDelete: (() -> Void)? = nil) {
        self.mode = mode
        self.onSave = onSave
        self.onDelete = onDelete
        self._localDraft = State(initialValue: draft) 
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(modeTitle)
                .font(.title2)
                .bold()

            Group {
                TextField("Name", text: $localDraft.name)
                TextField("Relationship to you", text: $localDraft.relationshipToUser)
                TextField("Hobbies (comma-separated)", text: $localDraft.hobbies)
                TextField("Interests (comma-separated)", text: $localDraft.interests)
                TextField("Connected User ID (optional)", text: $localDraft.connectedProfileID)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.red)
                .padding()

                Spacer()

                Button("Save") {
                    onSave(localDraft)
                    dismiss()
                }
                .disabled(localDraft.name.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding()
            }

            if case .edit = mode {
                Button("Delete Profile") {
                    onDelete?()
                    dismiss()
                }
                .foregroundColor(.red)
                .padding(.top)
            }
        }
        .padding()
    }

    private var modeTitle: String {
        switch mode {
        case .add: return "New Profile"
        case .edit: return "Edit Profile"
        }
    }
}
