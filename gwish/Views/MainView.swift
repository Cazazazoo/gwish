//
//  MainView.swift
//  gwish
//
//  Created by Connie Zhu on 4/25/25.
//

import SwiftUI

struct MainView: View {
    @State private var isSidebarVisible = false
    @State private var selectedScreen: SidebarOption = .wishlists
    @EnvironmentObject var authService: AuthService // Access AuthService to handle sign-out

    var body: some View {
        ZStack(alignment: .leading) {
            // Main content
            Group {
                switch selectedScreen {
                case .home:
                    EmptyView()
                case .wishlists:
                    WishlistView()
                case .profiles:
                    EmptyView()
                }
            }
            .disabled(isSidebarVisible)
            .overlay(
                Button(action: {
                    withAnimation {
                        isSidebarVisible.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .font(.title)
                        .padding()
                },
                alignment: .topLeading
            )
            
            // Dimmed overlay when sidebar is open
            if isSidebarVisible {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isSidebarVisible = false
                        }
                    }
                    .zIndex(0) // Below the sidebar
            }
            
            // Sidebar itself
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
                .zIndex(1) // On top of overlay
            }
        }
    }
    
    // Sign-out action
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
