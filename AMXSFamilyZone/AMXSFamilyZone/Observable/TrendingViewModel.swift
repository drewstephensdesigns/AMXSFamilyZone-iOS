//
//  TrendingViewModel.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 8/31/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class TrendingViewModel: ObservableObject {
    @Published var trendingPosts: [Post] = []
    @Published var newUsers: [User] = []
    
    private var db = Firestore.firestore()
    private var currentUserId: String {
            // Assuming you're using FirebaseAuth to get the current user's ID
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    init() {
        fetchTrendingPosts()
        fetchNewUsers()
    }
    
    func fetchTrendingPosts() {
        db.collection(Consts.POST_NODE)
            .order(by: "creatorId") // Add this to ensure the query is supported
            .order(by: "time", descending: true)
            .limit(to: 10)
            .whereField("creatorId", isNotEqualTo: currentUserId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot {
                        // print("Fetched documents: \(snapshot.documents.count)")
                    self.trendingPosts = snapshot.documents.compactMap { document -> Post? in
                        var post = try? document.data(as: Post.self)
                            // Debugging
                            // print("Post fetched: \(String(describing: post))")
                            // Ensure post is not nil and handle imageUrl properly
                        if post != nil {
                            post?.imageUrl = nil // Temporarily remove imageUrl
                        }
                        return post
                    }
                }
            }
    }
    
    func fetchNewUsers() {
        db.collection(Consts.USER_NODE)
            .order(by: "accountCreated", descending: true)
            .limit(to: 10)
            .whereField("id", isNotEqualTo: currentUserId) // Exclude current user
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching users: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.newUsers = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: User.self)
                }
                    //print("Fetched users: \(self.newUsers)")
            }
    }
}
