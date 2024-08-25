    //
    //  HomeFeed.swift
    //  AMXSFamilyZone
    //
    //  Created by Andrew Stephens on 6/7/24.
    //

import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class HomeFeed: ObservableObject {
    @Published var posts: [Post] = []
    private var db = Firestore.firestore()
    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }
    
    func fetchPosts() {
        guard let userId = currentUserID else { return }
        
        db.collection(Consts.POST_NODE)
            //.whereField("creatorId", isNotEqualTo: userId)
            .order(by: "creatorId")
            .order(by: "time", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
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
                
        }
    }
}
