//
//  LoginView.swift
//  gwish
//
//  Created by Connie Zhu on 2/26/25.
//

import SwiftUI

// TODO: implement forgot password

struct LoginSignUpView: View {
    @EnvironmentObject var authService: AuthService  // Access AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    // Start with Login page
    @State private var signUpPage = false
    @State private var isPasswordVisible = false

    var body: some View {
        VStack {
            Text(signUpPage ? "Create Your Account" : "Login")
                .font(.largeTitle)
                .padding()

            if signUpPage {
                // Signup fields
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
            // Login fields
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if isPasswordVisible {
                TextField("Enter your password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                SecureField("Enter your password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
            
            // Toggle between Login and Signup
            Button(action: {
                signUpPage.toggle()
            }) {
                Text(signUpPage ? "Already have an account? Login" : "Don't have an account? Sign Up")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding()
            
            Button(action: {
                if signUpPage {
                    authService.signUp(username: username, email: email, password: password) { result in
                        switch result {
                        case .success(let user):
                            // TODO: navigate to MainApp
                            print("Signed up as: \(user)")
                            
                        case .failure(let error):
                            print("Sign up error: \(error.localizedDescription)")
                        }
                    }
                } else {
                    authService.signIn(email: email, password: password) { result in
                        switch result {
                        case .success(let user):
                            // TODO: navigate to MainApp
                            print("Logged in as: \(user)")
                        case .failure(let error):
                            print("Login error: \(error.localizedDescription)")
                        }
                    }
                }
            }) {
                Text(signUpPage ? "Create Account" : "Login")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}
