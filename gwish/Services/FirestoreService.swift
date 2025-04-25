//
//  FirestoreService.swift
//  gwish
//
//  Created by Connie Zhu on 2/28/25.
//

import Foundation
import FirebaseFirestore

// TODO: figure out Views if its just a click and layer above current screen

// Define the protocol
protocol FirestoreServiceProtocol {
    func createWishlist(_ wishlist: Wishlist, completion: @escaping (Result<DocumentReference, Error>) -> Void)
    func fetchWishlists(forUser userID: String, completion: @escaping (Result<[Wishlist], Error>) -> Void)
    
    func addItem(toWishlist wishlistID: String, item: Item, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchItems(forWishlist wishlistID: String, completion: @escaping (Result<[Item], Error>) -> Void)
}

class FirestoreService: FirestoreServiceProtocol {
    // Singleton
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    // MARK: - Wishlist Methods

    func createWishlist(_ wishlist: Wishlist, completion: @escaping (Result<DocumentReference, Error>) -> Void) {
        do {
            let ref = try db
              .collection("wishlists")
              .addDocument(from: wishlist)
            completion(.success(ref))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchWishlists(forUser userID: String, completion: @escaping (Result<[Wishlist], Error>) -> Void) {
        db.collection("wishlists").whereField("userID", isEqualTo: userID).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let wishlists = documents.compactMap { try? $0.data(as: Wishlist.self) }
            completion(.success(wishlists))
        }
    }
    
    // MARK: - Item Methods
    
    func addItem(toWishlist wishlistID: String, item: Item, completion: @escaping (Result<Void, any Error>) -> Void) {
        do {
            let _ = try db.collection("wishlists").document(wishlistID).collection("items").addDocument(from: item) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchItems(forWishlist wishlistID: String, completion: @escaping (Result<[Item], any Error>) -> Void) {
        db.collection("wishlists").document(wishlistID).collection("items").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }

            let items = documents.compactMap { try? $0.data(as: Item.self) }
            completion(.success(items))
        }
    }
}
    

