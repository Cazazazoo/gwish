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
    @State private var itemDrafts: [ItemDraft] = [ItemDraft()]
    @State private var showItemDetail = false
    @State private var selectedDraftIndex: Int? = nil
    @State private var wishlistTitle = ""
    @State private var addItem = false // Toggle for showing item input

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
                                    showItemDetail = true
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
                    viewModel.isAddingWishlist = false
                }
                .padding()
                .foregroundColor(.red)

                Spacer()

                Button("Save") {
                    let newItems: [Item] = itemDrafts
                        .filter { !$0.name.isEmpty }
                        .map { draft in
                            Item(
                                name: draft.name,
                                price: Double(draft.price),
                                priority: draft.priority == .none ? nil : draft.priority,
                                url: draft.link.isEmpty ? nil : [draft.link],
                                location: draft.location.isEmpty ? nil : draft.location,
                                creationDate: Timestamp(date: Date()),
                                category: nil,
                                occasion: nil,
                                status: nil
                            )
                        }
                    
                    viewModel.createWishlist(title: wishlistTitle, initialItems: newItems)
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
        .sheet(isPresented: $showItemDetail) {
            if let index = selectedDraftIndex {
                ItemDetailView(item: $itemDrafts[index], mode: .add)
            }
        }
    }
}
