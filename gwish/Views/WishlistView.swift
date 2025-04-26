//
//  WishlistView.swift
//  gwish
//
//  Created by Connie Zhu on 3/15/25.
//

import SwiftUI

struct WishlistView: View {
    @StateObject private var viewModel = WishlistViewModel()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.wishlists, id: \.wishlistID) { wishlist in
                        Button(action: {
                            withAnimation {
                                // Handle selection / navigation
                            }
                        }) {
                            HStack {
                                Text(wishlist.title)
                                    .font(.title3)
                                    .padding(.leading)

                                Spacer()

                                Image(systemName: "arrow.right")
                                    .font(.headline)
                                    .padding(.trailing)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
            }

            // Floating Button (overlayed)
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
        .sheet(isPresented: $viewModel.isAddingWishlist) {
            AddWishlistView(viewModel: viewModel)
        }

    }
}
