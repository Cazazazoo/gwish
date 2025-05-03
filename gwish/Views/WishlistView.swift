//
//  WishlistView.swift
//  gwish
//
//  Created by Connie Zhu on 3/15/25.
//

import SwiftUI

private enum ActiveModal: Identifiable {
    case addWishlist
    case editItem(draft: ItemDraft, wishlistID: String)
    case addItem(wishlistID: String)

    var id: String {
        switch self {
        case .addWishlist: return "addWishlist"
        case .editItem(let draft, _): return "editItem-\(draft.id)"
        case .addItem(let id): return "addItem-\(id)"
        }
    }
}

struct WishlistView: View {
    @StateObject private var viewModel = WishlistViewModel()
    @State private var activeModal: ActiveModal? = nil

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
                                                viewModel.fetchItems(fromWishlistID: wishlistID)
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
                activeModal = .addWishlist
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
        .sheet(item: $activeModal) { modal in
            switch modal {
            case .addWishlist:
                AddWishlistView(viewModel: viewModel)
                
            case .editItem(let draft, let wishlistID):
                ItemDetailView(
                    item: draft,
                    mode: .edit,
                    onDone: { updatedDraft in
                        let updatedItem = updatedDraft.toItem()
                        viewModel.updateItem(inWishlist: wishlistID, itemID: draft.id, item: updatedItem)
                        activeModal = nil
                    }
                )
                
            case .addItem(let wishlistID):
                ItemDetailView(
                    item: ItemDraft(),
                    mode: .add,
                    onDone: { draft in
                        let newItem = draft.toItem()
                        viewModel.addItem(toWishlist: wishlistID, item: newItem)
                        activeModal = nil
                    }
                )
            }
        }
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
                    wishlistItemRow(item: item, wishlistID: wishlist.id)
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
                // TODO: add loading indicator?
                Button("Add an item") {
                    if let id = wishlist.id {
                        activeModal = .addItem(wishlistID: id)                    }
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
    
    private func wishlistItemRow(item: Item, wishlistID: String?) -> some View {
        HStack {
            Text(item.name)
                .underline()
                .onTapGesture {
                    if let wishlistID = wishlistID {
                        activeModal = .editItem(draft: ItemDraft(from: item), wishlistID: wishlistID)
                    }
                }
                .strikethrough(item.complete == true)
                .foregroundColor(item.complete == true ? .gray : .primary)
                .padding(.leading)
            
            Spacer()
            
            Button(item.complete == true ? "Incomplete" : "Complete") {
                if let wishlistID = wishlistID {
                    viewModel.toggleItemComplete(inWishlist: wishlistID, item: item)
                }
            }
            .font(.caption)
            .foregroundColor(item.complete == true ? .orange : .green)
            
            Button("Delete") {
                if let wishlistID = wishlistID {
                    viewModel.deleteItem(fromWishlist: wishlistID, item: item)
                }
            }
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding(.horizontal)
    }
}

private struct WishlistIDWrapper: Identifiable {
    let id: String
}
