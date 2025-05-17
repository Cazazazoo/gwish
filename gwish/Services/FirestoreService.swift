//
//  FirestoreService.swift
//  gwish
//
//  Created by Connie Zhu on 2/28/25.
//

import Foundation
import FirebaseFirestore

final class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}

    // MARK: - Add Document
    func addDocument<T: Encodable>(to collectionPath: String, data: T, completion: @escaping (Result<DocumentReference, Error>) -> Void) {
        do {
            let ref = try db.collection(collectionPath).addDocument(from: data)
            completion(.success(ref))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Fetch Documents with Optional Filtering
    func fetchDocuments<T: Decodable>(from collectionPath: String, as type: T.Type, whereField field: String? = nil, isEqualTo value: Any? = nil, completion: @escaping (Result<[T], Error>) -> Void) {
        var query: Query = db.collection(collectionPath)
        if let field = field, let value = value {
            query = query.whereField(field, isEqualTo: value)
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let documents = snapshot?.documents.compactMap { try? $0.data(as: T.self) } ?? []
            completion(.success(documents))
        }
    }
    
    // MARK: - Fetch Document by ID
    func fetchDocument<T: Decodable>(from collectionPath: String, documentId: String, as type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        db.collection(collectionPath)
            .document(documentId)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let document = snapshot, document.exists else {
                    completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found."])))
                    return
                }

                do {
                    let decoded = try document.data(as: T.self)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Update Document
    func updateDocument<T: Encodable>(in collectionPath: String, documentId: String, with data: T, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection(collectionPath)
                .document(documentId)
                .setData(from: data, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Delete Document
    func deleteDocument(from collectionPath: String, documentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionPath)
            .document(documentId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    // MARK: - Add Subdocument
    func addSubdocument<T: Encodable>(to parentCollection: String, parentId: String, subcollection: String, data: T, completion: @escaping (Result<DocumentReference, Error>) -> Void) {
        do {
            let ref = try db
                .collection(parentCollection)
                .document(parentId)
                .collection(subcollection)
                .addDocument(from: data)
            completion(.success(ref))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Fetch Subdocuments
    func fetchSubdocuments<T: Decodable>(from parentCollection: String, parentId: String, subcollection: String, as type: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
        db.collection(parentCollection)
            .document(parentId)
            .collection(subcollection)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let documents = snapshot?.documents.compactMap { try? $0.data(as: T.self) } ?? []
                completion(.success(documents))
            }
    }
    
    // MARK: - Update Subdocument
    func updateSubdocument<T: Encodable>(in parentCollection: String, parentId: String, subcollection: String, documentId: String, with data: T, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection(parentCollection)
                .document(parentId)
                .collection(subcollection)
                .document(documentId)
                .setData(from: data, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Delete Subdocument
    func deleteSubdocument(from parentCollection: String, parentId: String, subcollection: String, documentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(parentCollection)
            .document(parentId)
            .collection(subcollection)
            .document(documentId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}


