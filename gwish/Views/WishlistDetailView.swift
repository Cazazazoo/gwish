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

    @ObservedObject var viewModel: WishlistViewModel

    @State private var title: String
    @State private var isPublic: Bool
    @State private var showItemSheet = false
    @State private var editingItem: ItemDraft?

    @Environment(\.dismiss) private var dismiss

    init(
        wishlist: Wishlist,
        viewModel: WishlistViewModel,
        onSave: @escaping (_ newTitle: String, _ isPublic: Bool) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.wishlist = wishlist
        self.viewModel = viewModel
        self.onSave = onSave
        self.onDelete = onDelete

        _title = State(initialValue: wishlist.title)
        _isPublic = State(initialValue: wishlist.isPublic ?? false)
    }

    var body: some View {
        Form {
            Section(header: Text("Wishlist Info")) {
                TextField("Wishlist Title", text: $title)
                Toggle("Public", isOn: $isPublic)
            }

            Section(header: Text("Items")) {
                if let wishlistID = wishlist.id,
                   let items = viewModel.wishlistItems[wishlistID], !items.isEmpty {
                    ForEach(items) { item in
                        HStack {
                            Text(item.name)
                                .onTapGesture {
                                    editingItem = ItemDraft(from: item)
                                }
                                .strikethrough(item.complete == true)
                                .foregroundColor(item.complete == true ? .gray : .primary)

                            Spacer()

                            Button(item.complete == true ? "Mark Incomplete" : "Complete") {
                                guard item.id != nil else {
                                    Logger.error("Missing item ID for toggle complete")
                                    return
                                }
                                viewModel.toggleItemComplete(inWishlist: wishlistID, item: item)
                            }
                            .font(.caption)

                            Button("Delete") {
                                viewModel.deleteItem(fromWishlist: wishlistID, item: item)
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    }
                } else {
                    Text("No items yet")
                        .foregroundColor(.gray)
                }

                Button("Add Item") {
                    showItemSheet = true
                }
            }

            Section {
                Button("Delete Wishlist", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
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
        .sheet(isPresented: $showItemSheet) {
            ItemDetailView(item: ItemDraft(), mode: .add, onDone: { newItem in
                if let wishlistID = wishlist.id {
                    viewModel.addItem(toWishlist: wishlistID, item: newItem.toItem())
                }
                showItemSheet = false
            })
        }
        .sheet(item: $editingItem) { draft in
            ItemDetailView(item: draft, mode: .edit, onDone: { updated in
                if let wishlistID = wishlist.id {
                    viewModel.updateItem(inWishlist: wishlistID, itemID: updated.id, item: updated.toItem())
                }
                editingItem = nil
            })
        }
    }
}
