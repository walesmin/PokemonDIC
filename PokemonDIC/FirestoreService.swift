//
//  FirestoreService.swift
//  PokemonDIC
//
//  Created by 민경빈 on 6/15/24.
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func addBookmark(bookmark: Bookmark, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection("bookmarks").document(bookmark.id).setData(from: bookmark, completion: completion)
        } catch let error {
            completion(error)
        }
    }
    
    func removeBookmark(bookmarkId: String, completion: @escaping (Error?) -> Void) {
        db.collection("bookmarks").document(bookmarkId).delete(completion: completion)
    }
    
    func fetchBookmarks(completion: @escaping ([Bookmark]?, Error?) -> Void) {
        db.collection("bookmarks").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let bookmarks = snapshot?.documents.compactMap { document -> Bookmark? in
                try? document.data(as: Bookmark.self)
            }
            completion(bookmarks, nil)
        }
    }

    func isBookmarked(pokemonId: String, completion: @escaping (Bool) -> Void) {
        db.collection("bookmarks").document(pokemonId).getDocument { document, error in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
