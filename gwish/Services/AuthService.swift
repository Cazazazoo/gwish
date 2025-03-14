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
    private let db = Firestore.firestore()
    
    var isAuthenticated: Bool {
        return user != nil
    }
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Listen to auth state changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, authUser in
            if let authUser = authUser {
                self.fetchUserFromFirestore(uid: authUser.uid)
            } else {
                self.user = nil
            }
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
            guard let authUser = result?.user else {
                completion(.failure(NSError(domain: "No user", code: -1, userInfo: nil)))
                return
            }
            
            let newUser = User(userID: authUser.uid, username: username, createdDate: Timestamp(date: Date()))
        
            do {
                try self.db.collection("users").document(authUser.uid).setData(from: newUser) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        DispatchQueue.main.async {
                            self.user = newUser
                        }
                        completion(.success(newUser))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let authUser = result?.user else {
                completion(.failure(NSError(domain: "No user", code: -1, userInfo: nil)))
                return
            }
            
            // Retrieve from Firestore after login
            let db = Firestore.firestore()
            self.fetchUserFromFirestore(uid: authUser.uid, completion: completion)
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
    
    // MARK: - Firestore Fetch (Using Codable)
        private func fetchUserFromFirestore(uid: String, completion: ((Result<User, Error>) -> Void)? = nil) {
            let userRef = db.collection("users").document(uid)

            userRef.getDocument { document, error in
                if let error = error {
                    completion?(.failure(error))
                    return
                }
                guard let document = document, document.exists else {
                    completion?(.failure(NSError(domain: "Document not found", code: -1, userInfo: nil)))
                    return
                }

                do {
                    let user = try document.data(as: User.self) // Automatically decodes
                    DispatchQueue.main.async {
                        self.user = user
                    }
                    completion?(.success(user))
                } catch {
                    completion?(.failure(error))
                }
            }
        }
}
