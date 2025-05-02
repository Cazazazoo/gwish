//
//  WishlistView.swift
//  gwish
//
//  Created by Connie Zhu on 3/15/25.
//

import SwiftUI

struct WishlistView: View {
    @StateObject private var viewModel = WishlistViewModel()
    @State private var selectedItemDraft: ItemDraft? = nil
    @State private var currentEditingWishlistID: String? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(red: 245/255, green: 245/255, blue: 255/255) // Soft lavender-tinted background
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.wishlists.isEmpty {
                        Text("No Wishlists")
                            .font(.headline)
                            .padding()
                    } else {
                        ForEach(viewModel.wishlists) { wishlist in
                            VStack(spacing: 0) {
                                Button(action: {
                                    if let wishlistID = wishlist.id {
                                        withAnimation {
                                            viewModel.toggleExpanded(wishlistID: wishlistID)
                                            if viewModel.expandedWishlistIDs.contains(wishlistID),
                                               (wishlist.items == nil || wishlist.items?.isEmpty == true) {
                                                viewModel.fetchItems(forWishlistID: wishlistID)
                                            }
                                        }
                                    }
                                }) {
                                    HStack {
                                        Label(wishlist.title, systemImage: "gift.fill")
                                            .font(.title3)
                                            .fontWeight(.semibold)
//                                            .foregroundColor(Color.purple)
                                            .padding(.leading)

                                        Spacer()

                                        if let wishlistID = wishlist.id {
                                            Image(systemName: viewModel.expandedWishlistIDs.contains(wishlistID) ? "chevron.down" : "chevron.right")
                                                .font(.headline)
                                                .padding(.trailing)
                                        }
                                    }
                                    .frame(height: 60)
                                    .contentShape(Rectangle()) // Improves tap area
                                }
                                .padding(.horizontal)

                                if viewModel.expandedWishlistIDs.contains(wishlist.id ?? "") {
                                    Divider()
                                        .padding(.horizontal)

                                    wishlistExpandedView(for: wishlist)
                                        .padding(.top, 8)
                                }
                            }
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white, Color(red: 250/255, green: 250/255, blue: 255/255)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )                            
                            .cornerRadius(12)
                            .shadow(color: Color.purple.opacity(0.15), radius: 6, x: 0, y: 3)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(.top)
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Force full height
            }

            Button(action: {
                viewModel.isAddingWishlist = true
            }) {
                Image(systemName: "plus")
                    .font(.title)
                    .frame(width: 55, height: 55)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    .padding()
            }
        }
        // Adding wishlist
        .sheet(isPresented: $viewModel.isAddingWishlist) {
            AddWishlistView(viewModel: viewModel)
        }
        // Editing item from drop-down
        .sheet(item: $selectedItemDraft) { draft in
            ItemDetailView(
                item: draft,
                mode: .edit,
                onDone: { updatedDraft in
                    if let wishlistID = currentEditingWishlistID {
                        let updatedItem = updatedDraft.toItem()
                        viewModel.updateItem(inWishlist: wishlistID, itemID: draft.id, item: updatedItem)
                    }
                    currentEditingWishlistID = nil
                }
            )
        }
        // Adding item from drop-down
        .onAppear {
            viewModel.fetchWishlists()
        }
    }

    // MARK: - Subviews

    // Later, put some of these into their own views
    private func wishlistExpandedView(for wishlist: Wishlist) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let items = wishlist.items, !items.isEmpty {
                ForEach(items, id: \.id) { item in
                    HStack {
                        Text(item.name)
                            .underline()
                            .onTapGesture {
                                selectedItemDraft = ItemDraft(from: item)
                                currentEditingWishlistID = wishlist.id
                            }
                            .strikethrough(item.complete == true)
                            .foregroundColor(item.complete == true ? .gray : .primary)
                            .padding(.leading)
                        
                        Spacer()

                        Button("Complete") {
                            // TODO
                        }
                        .font(.caption)
                        .foregroundColor(Color.green)

                        Button("Delete") {
                            // TODO
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("No items in this wishlist")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }

            Divider()
                .padding(.horizontal)

            HStack {
                Button("Add an item") {
                    // TODO
                }

                Spacer()

                Button("Edit") {
                    // TODO
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
