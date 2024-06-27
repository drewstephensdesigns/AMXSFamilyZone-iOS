//
//  HomeFeed.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/7/24.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

class HomeFeed: ObservableObject {
    @Published var posts: [Post] = []
    private var db = Firestore.firestore()

    func fetchPosts() {
        db.collection("Post").order(by: "time", descending: true).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.posts = documents.compactMap { queryDocumentSnapshot in
                return try? queryDocumentSnapshot.data(as: Post.self)
            }
            
           // print("Fetched posts: \(self.posts)") // Debugging print
        }
    }
}
