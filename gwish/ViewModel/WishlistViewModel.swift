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
    
    private let firestoreService: FirestoreServiceProtocol
    
    init(firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.firestoreService = firestoreService
        fetchWishlists()
    }
    
    func fetchWishlists() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        firestoreService.fetchWishlists(forUser: userID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wishlists):
                    self?.wishlists = wishlists
                case .failure(let error):
                    // Handle the error (e.g., show an alert)
                    print("Error fetching wishlists: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func createWishlist(title: String, initialItem: Item?) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Create the document reference first to get an ID
        let docRef = Firestore.firestore().collection("wishlists").document()
        let wishlistID = docRef.documentID
        
        let newWishlist = Wishlist(
            wishlistID: wishlistID,
            title: title,
            lastUpdated: Timestamp(date: Date()),
            userID: userID,
            creationDate: Timestamp(date: Date())
        )

        firestoreService.createWishlist(newWishlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let initialItem = initialItem {
                        self?.addItem(toWishlist: wishlistID, item: initialItem)
                    } else {
                        self?.fetchWishlists()
                        self?.isAddingWishlist = false
                    }
                case .failure(let error):
                    print("Error creating wishlist: \(error.localizedDescription)")
                }
            }
        }
    }

    func addItem(toWishlist wishlistID: String, item: Item) {
        firestoreService.addItem(toWishlist: wishlistID, item: item) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchWishlists()
                    self?.isAddingWishlist = false
                case .failure(let error):
                    print("Error adding item: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
}
