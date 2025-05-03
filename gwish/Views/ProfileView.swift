//
//  ProfileView.swift
//  gwish
//
//  Created by Connie Zhu on 5/3/25.
//

import SwiftUI

private enum ActiveProfileModal: Identifiable {
    case addProfile
    case editProfile(Profile)

    var id: String {
        switch self {
        case .addProfile: return "addProfile"
        case .editProfile(let profile): return "editProfile-\(profile.id ?? "unknown")"
        }
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var activeModal: ActiveProfileModal?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.profiles.isEmpty {
                        Text("No Profiles")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.profiles) { profile in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profile.name)
                                        .font(.headline)
                                    if let relationship = profile.relationshipToUser {
                                        Text(relationship)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }

                                Spacer()

                                Button(action: {
                                    activeModal = .editProfile(profile)
                                }) {
                                    Image(systemName: "pencil")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
            }

            Button(action: {
                activeModal = .addProfile
            }) {
                Image(systemName: "plus")
                    .font(.title)
                    .frame(width: 55, height: 55)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
                    .padding()
            }
        }
        .onAppear {
            viewModel.fetchProfiles()
        }
        .sheet(item: $activeModal) { modal in
            switch modal {
            case .addProfile:
                ProfileDetailView(
                    mode: .add,
                    draft: ProfileDraft(),
                    onSave: { draft in
                        viewModel.addProfile(from: draft)
                        activeModal = nil
                    }
                )

            case .editProfile(let profile):
                ProfileDetailView(
                    mode: .edit(profile),
                    draft: ProfileDraft(profile: profile),
                    onSave: { draft in
                        viewModel.updateProfile(from: draft, originalProfile: profile) 
                        activeModal = nil
                    },
                    onDelete: {
                        viewModel.deleteProfile(profile)
                        activeModal = nil
                    }
                )
            }
        }

    }
}
