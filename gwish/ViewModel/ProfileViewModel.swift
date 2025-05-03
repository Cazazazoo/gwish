//
//  ProfileViewModel.swift
//  gwish
//
//  Created by Connie Zhu on 5/3/25.
//

import Foundation
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var profiles: [Profile] = []
    
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
        profileService.createProfile(for: userID, profile: profile) { [weak self] result in
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
        let profile = draft.toProfile(userID: originalProfile.userID) // preserve ID and user
        var updated = profile
        updated.id = profileID

        profileService.updateProfile(for: profileID, profile: updated) { [weak self] result in
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
        
        profileService.deleteProfile(profileId: profileId) { [weak self] result in
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
}
