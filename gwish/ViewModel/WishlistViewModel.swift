//
//  WishlistViewModel.swift
//  gwish
//
//  Created by Connie Zhu on 2/28/25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class WishlistViewModel: ObservableObject {
    @Published var wishlists: [Wishlist] = []
    // TODO: Add     @Published var isLoading = false
    @Published var isAddingWishlist = false // Controls pop-up visibility
    @Published var expandedWishlistIDs: Set<String> = []
    
    private let wishlistService: WishlistService
    private let itemService: ItemService

    init(
        wishlistService: WishlistService = WishlistService(),
        itemService: ItemService = ItemService()
    ) {
        self.wishlistService = wishlistService
        self.itemService = itemService
    }
    
    func toggleExpanded(wishlistID: String) {
        if expandedWishlistIDs.contains(wishlistID) {
            expandedWishlistIDs.remove(wishlistID)
        } else {
            expandedWishlistIDs.insert(wishlistID)
        }
    }
    
    // MARK: - Wishlist
    
    func fetchWishlists() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        wishlistService.fetchWishlists(forUser: userID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wishlists):
                    self?.wishlists = wishlists
                case .failure(let error):
                    // Handle the error (e.g., show an alert)
                    Logger.error("Error fetching wishlists: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func createWishlist(title: String, initialItems: [Item]) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let newWishlist = Wishlist(
            title: title,
            lastUpdated: Timestamp(date: Date()),
            userID: userID,
            creationDate: Timestamp(date: Date())
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
                    self?.isAddingWishlist = false
                    
                case .failure(let error):
                    Logger.error("Error creating wishlist: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Item
    
    func addItem(toWishlist wishlistID: String, item: Item) {
        itemService.addItem(toWishlist: wishlistID, item: item) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchWishlists()
                    self?.isAddingWishlist = false
                case .failure(let error):
                    Logger.error("Error adding item: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchItems(forWishlistID wishlistID: String) {
        itemService.fetchItems(forWishlist: wishlistID) { [weak self] result in
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
                    self?.fetchItems(forWishlistID: wishlistID)
                case .failure(let error):
                    Logger.error("Error updating item: \(error.localizedDescription)")
                }
            }
        }
    }
}
