//
//  WishlistDetailView.swift
//  gwish
//
//  Created by Connie Zhu on 5/2/25.
//

import SwiftUI

struct WishlistDetailView: View {
    let wishlist: Wishlist
    var onSave: (_ newTitle: String, _ isPublic: Bool) -> Void
    var onDelete: () -> Void

    @State private var title: String
    @State private var isPublic: Bool

    @Environment(\.dismiss) private var dismiss

    // Need to pass information in
    init(
        wishlist: Wishlist,
        onSave: @escaping (_ newTitle: String, _ isPublic: Bool) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.wishlist = wishlist
        self.onSave = onSave
        self.onDelete = onDelete

        _title = State(initialValue: wishlist.title)
        _isPublic = State(initialValue: wishlist.isPublic ?? false)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Wishlist Name", text: $title)

                    Toggle("Public", isOn: $isPublic)
                }

                Section {
                    Button("Delete Wishlist", role: .destructive) {
                        onDelete()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Wishlist")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave(title, isPublic)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
