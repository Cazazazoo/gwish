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

// ViewModel example for managing the wishlist data:
class WishlistViewModel: ObservableObject {
    @Published var wishlists: [Wishlist] = []
    // TODO: Add     @Published var isLoading = false
    @Published var isAddingWishlist = false // Controls pop-up visibility
    
    private let wishlistService: WishlistService
    private let itemService: ItemService

    init(
        wishlistService: WishlistService = WishlistService(),
        itemService: ItemService = ItemService()
    ) {
        self.wishlistService = wishlistService
        self.itemService = itemService
        fetchWishlists()
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
    
    func createWishlist(title: String, initialItem: Item?) {
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
                    if let initialItem = initialItem {
                        self?.addItem(toWishlist: wishlistID, item: initialItem)
                    } else {
                        self?.fetchWishlists()
                        self?.isAddingWishlist = false
                    }
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
}
