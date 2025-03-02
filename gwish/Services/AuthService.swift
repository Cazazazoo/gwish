//
//  AuthService.swift
//  gwish
//
//  Created by Connie Zhu on 2/25/25.
//

//import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

// TODO: incorporate the firestore stuff with the User struc

class AuthService: ObservableObject {
    @Published var user: User? // User state, automatically updates UI, source of truth
    var isAuthenticated: Bool {
        return user != nil
    }
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Listen to auth state changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            self.user = user
        }
    }
    
    // Get result User object or error from success or failure
    func signUp(username: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Closure, "in" separates parameters from closure
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            // Only care about error in this loop so used let
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "No user", code: -1, userInfo: nil)))
                return
            }
            
            // After successful auth, save username to Firestore
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)
            
            // Save the username and other details to Firestore
            userRef.setData([
                "username": username,
                "email": email,
                "uid": user.uid
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Update the published user property
                // Ensure this UI update happens on the main thread
                DispatchQueue.main.async {
                    self.user = user
                }
                completion(.success(user))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "No user", code: -1, userInfo: nil)))
                return
            }
            
            // Retrieve from Firestore after login
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)
            
            userRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let username = document.get("username") as? String {
                        // Successfully retrieved the username
                        print("Username: \(username)")
                    }
                }
            }
            
            // Update the published user property
            DispatchQueue.main.async {
                self.user = user
            }
            completion(.success(user))
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
            }
            completion(.success(())) // Void or Error goes in here based on Result
        } catch let error {
            completion(.failure(error))
        }
    }
    
//    func ifUserSignedIn() -> Bool {
//        return user != nil
//    }
}
