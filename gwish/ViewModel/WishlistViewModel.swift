//
//  WishlistViewModel.swift
//  gwish
//
//  Created by Connie Zhu on 2/28/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class WishlistViewModel: ObservableObject {
    @Published var wishlists: [Wishlist] = []
    @Published var expandedWishlistIDs: Set<String> = []
    // TODO: Add     @Published var isLoading = false
    
    // Services
    private let wishlistService: WishlistService
    private let itemService: ItemService

    init(
        wishlistService: WishlistService = WishlistService(),
        itemService: ItemService = ItemService()
    ) {
        self.wishlistService = wishlistService
        self.itemService = itemService
    }
    
    // MARK: - Toggles
    
    func toggleExpanded(wishlistID: String) {
        if expandedWishlistIDs.contains(wishlistID) {
            expandedWishlistIDs.remove(wishlistID)
        } else {
            expandedWishlistIDs.insert(wishlistID)
        }
    }
    
    func toggleItemComplete(inWishlist wishlistID: String, item: Item) {
        var updatedItem = item
        updatedItem.complete = !(item.complete ?? false)

        updateItem(inWishlist: wishlistID, itemID: item.id ?? "", item: updatedItem)
    }
    
    // MARK: - Wishlist
    
    func fetchWishlists(completion: (() -> Void)? = nil) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        wishlistService.fetchWishlists(forUser: userID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wishlists):
                    self?.wishlists = wishlists
                    completion?()
                case .failure(let error):
                    // Handle the error (e.g., show an alert)
                    Logger.error("Error fetching wishlists: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func createWishlist(title: String, initialItems: [Item], isPublic: Bool) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let newWishlist = Wishlist(
            title: title,
            lastUpdated: Timestamp(date: Date()),
            userID: userID,
            creationDate: Timestamp(date: Date()),
            isPublic: isPublic
        )

        wishlistService.createWishlist(newWishlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ref):
                    let wishlistID = ref.documentID
                    
                    if !initialItems.isEmpty {
                        // If there are items to add, add them all
                        for item in initialItems {
                            self?.addItem(toWishlist: wishlistID, item: item)
                        }
                    }

                    // Refresh wishlists and dismiss
                    self?.fetchWishlists()
                    
                case .failure(let error):
                    Logger.error("Error creating wishlist: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateWishlist(_ wishlist: Wishlist) {
        wishlistService.updateWishlist(wishlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchWishlists() // Refresh to reflect updates
                    
                    // Re-fetch items for the updated wishlist
                    if let wishlistID = wishlist.id {
                        Logger.info("NEW ISSUE")
                        self?.fetchItems(fromWishlistID: wishlistID)
                    }
                    
                case .failure(let error):
                    Logger.error("Error updating wishlist: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteWishlist(_ wishlist: Wishlist) {
        wishlistService.deleteWishlist(wishlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.wishlists.removeAll { $0.id == wishlist.id }
                case .failure(let error):
                    Logger.error("Error deleting wishlist: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Item
    
    func addItem(toWishlist wishlistID: String, item: Item) {
        // No empty names
        guard !item.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        itemService.addItem(toWishlist: wishlistID, item: item) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchWishlists {
                        // After fetching wishlists, re-fetch items for expanded ones
                        for id in self?.expandedWishlistIDs ?? [] {
                            self?.fetchItems(fromWishlistID: id) // runs after list is refreshed
                        }
                    }
                case .failure(let error):
                    Logger.error("Error adding item: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchItems(fromWishlistID wishlistID: String) {
        itemService.fetchItems(fromWishlist: wishlistID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    if let index = self?.wishlists.firstIndex(where: { $0.id == wishlistID }) {
                        self?.wishlists[index].items = items
                    }
                case .failure(let error):
                    Logger.error("Error fetching items for wishlist: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateItem(inWishlist wishlistID: String, itemID: String, item: Item) {
        itemService.updateItem(inWishlist: wishlistID, itemID: itemID, item: item) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchItems(fromWishlistID: wishlistID)
                case .failure(let error):
                    Logger.error("Error updating item: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteItem(fromWishlist wishlistID: String, item: Item) {
        guard let itemId = item.id else {
            Logger.error("Missing item ID for deletion")
            return
        }

        itemService.deleteItem(fromWishlist: wishlistID, itemID: itemId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchItems(fromWishlistID: wishlistID)
                case .failure(let error):
                    Logger.error("Error deleting item: \(error.localizedDescription)")
                }
            }
        }
    }
}
