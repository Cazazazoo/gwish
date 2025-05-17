//
//  ProfileWishlistView.swift
//  gwish
//
//  Created by Connie Zhu on 5/16/25.
//

import SwiftUI

struct ProfileWishlistView: View {
    let wishlist: Wishlist

    @StateObject private var wishlistViewModel = WishlistViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()

    @State private var profile: Profile?

    var body: some View {
        VStack(spacing: 16) {
            if let profile = profile {
                NavigationLink(
                    destination: ProfileDetailView(
                        mode: .edit(profile),
                        draft: ProfileDraft(profile: profile),
                        profileViewModel: profileViewModel,
                        onSave: { updated in
                            profileViewModel.updateProfile(from: updated, originalProfile: profile)
                        },
                        onDelete: {
                            profileViewModel.deleteProfile(profile)
                        }
                    )
                ) {
                    HStack {
                        Text("Wishlist for:")
                        Spacer()
                        Text(profile.name)
                            .foregroundColor(.blue)
                            .bold()
                    }
                    .padding(.horizontal)
                }
            }

            WishlistDetailView(
                wishlist: wishlist,
                viewModel: wishlistViewModel,
                onSave: { newTitle, isPublic in
                    var updated = wishlist
                    updated.title = newTitle
                    updated.isPublic = isPublic
                    wishlistViewModel.updateWishlist(updated)
                },
                onDelete: {
                    wishlistViewModel.deleteWishlist(wishlist)
                }
            )
        }
        .onAppear {
            if let profileID = wishlist.profileID {
                profileViewModel.fetchProfile(withID: profileID) { fetched in
                    self.profile = fetched
                }
            }

            if let id = wishlist.id {
                wishlistViewModel.fetchItems(fromWishlistID: id)
            }
        }
        .navigationTitle("Wishlist Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
>>>>>>> 2643c06 (update wishlist details)
