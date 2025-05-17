//
//  MainView.swift
//  gwish
//
//  Created by Connie Zhu on 4/25/25.
//

import SwiftUI

// TODO: Add settings for profile pic

struct MainView: View {
    @State private var isSidebarVisible = false
    @State private var selectedScreen: SidebarOption = .wishlists
    @EnvironmentObject var authService: AuthService // Access AuthService to handle sign-out
    
    private var currentTitle: String {
        switch selectedScreen {
//        case .home:
//            return "gwish"
        case .wishlists:
            return "Your Wishlists"
        case .profiles:
            return "Profiles"
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                // Shared Top Bar
                TopBarView(
                    onProfileTap: {
                        withAnimation {
                            isSidebarVisible.toggle()
                        }
                    },
                    onFilterTap: {
                        // filter action
                    },
                    title: currentTitle
                )

                Divider()

                // Main Screen Content
                Group {
                    switch selectedScreen {
//                    case .home:
//                        EmptyView()
                    case .wishlists:
                        WishlistView()
                    case .profiles:
                        ProfileView()
                    }
                }
            }
            .disabled(isSidebarVisible)

            // Background overlay
            if isSidebarVisible {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isSidebarVisible = false
                        }
                    }
                    .zIndex(0)
            }

            // Sidebar
            if isSidebarVisible {
                SidebarView(
                    onSelect: { selected in
                        withAnimation {
                            selectedScreen = selected
                            isSidebarVisible = false
                        }
                    },
                    onLogout: {
                        withAnimation {
                            isSidebarVisible = false
                        }
                        signOut()
                    }
                )
                .frame(width: 250)
                .background(Color(.systemGray6))
                .transition(.move(edge: .leading))
                .zIndex(1)
            }
        }
    }

    private func signOut() {
        authService.signOut { result in
            switch result {
            case .success:
                // Handle successful sign-out (e.g., redirect to login view)
                Logger.debug("Successfully signed out")
            case .failure(let error):
                // Handle error during sign-out
                Logger.error("Sign-out failed: \(error.localizedDescription)")
            }
        }
    }
}
