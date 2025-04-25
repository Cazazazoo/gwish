//
//  WishlistView.swift
//  gwish
//
//  Created by Connie Zhu on 3/15/25.
//

import SwiftUI

struct WishlistView: View {
    @StateObject private var viewModel = WishlistViewModel()
    @State private var expandedWishlistID: String? // Tracks expanded wishlist
    @EnvironmentObject var authService: AuthService // Access AuthService to handle sign-out

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.wishlists, id: \.wishlistID) { wishlist in
                        Section(header: WishlistHeader(wishlist: wishlist, expandedWishlistID: $expandedWishlistID)) {
                            if expandedWishlistID == wishlist.wishlistID {
                                Text("Items will go here") // Placeholder
                            }
                        }
                    }
                }
            }
            .navigationTitle("Wishlists")
            .toolbar {
                // Sign-out button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: signOut) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
                
                // Add button for wishlist creation
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.isAddingWishlist = true
                    }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isAddingWishlist) {
                AddWishlistView(viewModel: viewModel)
            }
        }
    }
    // Sign-out action
    private func signOut() {
        authService.signOut { result in
            switch result {
            case .success:
                // Handle successful sign-out (e.g., redirect to login view)
                print("Successfully signed out")
            case .failure(let error):
                // Handle error during sign-out
                print("Sign-out failed: \(error.localizedDescription)")
            }
        }
    }
}

// Expandable header
struct WishlistHeader: View {
    let wishlist: Wishlist
    @Binding var expandedWishlistID: String?

    var body: some View {
        Button(action: {
            withAnimation {
                expandedWishlistID = (expandedWishlistID == wishlist.wishlistID) ? nil : wishlist.wishlistID
            }
        }) {
            HStack {
                Text(wishlist.title)
                    .font(.headline)
                Spacer()
                Image(systemName: expandedWishlistID == wishlist.wishlistID ? "chevron.down" : "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(10)
    }
}
