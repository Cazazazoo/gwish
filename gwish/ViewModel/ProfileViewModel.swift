//
//  ProfileViewModel.swift
//  gwish
//
//  Created by Connie Zhu on 5/3/25.
//

import Foundation
import FirebaseAuth
import FirebaseCore

class ProfileViewModel: ObservableObject {
    @Published var profiles: [Profile] = []
    private let wishlistService = WishlistService()
    
    private let profileService: ProfileService
    
    init(profileService: ProfileService = ProfileService()) {
        self.profileService = profileService
    }
    
    func fetchProfiles() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        profileService.fetchProfiles(for: userID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profiles):
                    self?.profiles = profiles
                case .failure(let error):
                    Logger.error("Failed to fetch profiles: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addProfile(from draft: ProfileDraft) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let profile = draft.toProfile(userID: userID)
        profileService.createProfile(profile) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchProfiles()
                case .failure(let error):
                    Logger.error("Error adding profile: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateProfile(from draft: ProfileDraft, originalProfile: Profile) {
        guard let profileID = originalProfile.id else { return }

        var updated = draft.toProfile(userID: originalProfile.userID)
        updated.id = profileID //

        profileService.updateProfile(updated) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchProfiles()
                case .failure(let error):
                    Logger.error("Error updating profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteProfile(_ profile: Profile) {
        guard let profileId = profile.id else { return }
        
        profileService.deleteProfile(profile) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.profiles.removeAll { $0.id == profileId }
                case .failure(let error):
                    Logger.error("Failed to delete profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Wishlists
    func createOrUpdateWishlist(
        title: String,
        items: [Item],
        isPublic: Bool,
        profileID: String,
        completion: (() -> Void)? = nil
    ) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let wishlist = Wishlist(
            title: title,
            lastUpdated: Timestamp(date: Date()),
            userID: userID,
            creationDate: Timestamp(date: Date()),
            isPublic: isPublic,
            profileID: profileID
        )

        wishlistService.createWishlist(wishlist) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ref):
                    for item in items {
                        self.addItem(toWishlist: ref.documentID, item: item)
                    }
                    completion?()
                case .failure(let error):
                    Logger.error("Failed to create wishlist: \(error)")
                }
            }
        }
    }

    private func addItem(toWishlist wishlistID: String, item: Item) {
        ItemService().addItem(toWishlist: wishlistID, item: item) { result in
            if case .failure(let error) = result {
                Logger.error("Failed to add item: \(error)")
            }
        }
    }
}
