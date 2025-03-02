//
//  ContentView.swift
//  gwish
//
//  Created by Connie Zhu on 2/25/25.
//

import SwiftUI

// UI Logic/Entry Point
struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                // Show wishlist view if authenticated
                EmptyView()
            } else {
                // Show login view if not authenticated
                LoginSignUpView()
            }
        }
    }
}

#Preview {
    ContentView()
}
