//
//  WishlistViewModel.swift
//  gwish
//
//  Created by Connie Zhu on 2/28/25.
//

import Foundation

//// ViewModel example for managing the wishlist data:
//class WishlistViewModel: ObservableObject {
//    @Published var wishlistItems: [WishlistItem] = []
//    
//    func fetchWishlistItems(userId: String, wishlistId: String) {
//        FirestoreService.shared.getWishlistItems(userId: userId, wishlistId: wishlistId) { result in
//            switch result {
//            case .success(let items):
//                self.wishlistItems = items
//            case .failure(let error):
//                print("Failed to fetch wishlist items: \(error)")
//            }
//        }
//    }
//}
