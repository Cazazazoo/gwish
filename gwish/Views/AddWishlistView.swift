//
//  AddWishlistView.swift
//  gwish
//
//  Created by Connie Zhu on 3/15/25.
//

import SwiftUI
import FirebaseCore

struct AddWishlistView: View {
    @ObservedObject var viewModel: WishlistViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var itemDrafts: [ItemDraft] = [ItemDraft()]
    @State private var selectedDraftIndex: Int? = nil
    @State private var wishlistTitle = ""
    @State private var addItem = false // Toggle for showing item input
    @State private var editingDraft: ItemDraft? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("New Wishlist")
                .font(.title2)
                .bold()

            TextField("Enter wishlist title", text: $wishlistTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Toggle("Add an item", isOn: $addItem)
                .padding()

            if addItem {
                VStack(spacing: 12) {
                    ForEach(itemDrafts.indices, id: \.self) { index in
                        let draft = itemDrafts[index]

                        HStack {
                            // Different placeholder for first item
                            TextField(
                                index == 0 ? "Enter item name" : "Add another item..",
                                text: $itemDrafts[index].name
                            )
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            Spacer()

                            if !draft.name.isEmpty {
                                Button("Edit Details") {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    selectedDraftIndex = index
                                    editingDraft = draft
                                }
                            }
                        }
                        // Only append a new item if this is the last item and it's now non-empty
                        .onChange(of: draft.name) { oldValue, newValue in
                            let isLast = index == itemDrafts.count - 1
                            
                            if isLast && !newValue.isEmpty {
                                if itemDrafts.count < 5 {
                                    itemDrafts.append(ItemDraft())
                                }
                            } else if !isLast && newValue.isEmpty {
                                // Remove if it's not the first and not the last item (the persistent blank one)
                                if index != 0 && index != itemDrafts.count - 1 {
                                    _ = withAnimation {
                                        itemDrafts.remove(at: index)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .padding()
                .foregroundColor(.red)

                Spacer()

                Button("Save") {
                    let newItems = itemDrafts
                        .filter { !$0.name.isEmpty }
                        .map { $0.toItem() }
                    viewModel.createWishlist(title: wishlistTitle, initialItems: newItems)
                    dismiss()
                }
                .padding()
                .disabled(wishlistTitle.isEmpty)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .padding()
        .sheet(item: $editingDraft) { draft in
            ItemDetailView(item: draft, mode: .add, onDone: { updated in
                if let index = selectedDraftIndex {
                    itemDrafts[index] = updated
                }
                selectedDraftIndex = nil
                editingDraft = nil
            })
        }
    }
}
