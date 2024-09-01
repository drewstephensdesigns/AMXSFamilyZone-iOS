//
//  TrendingView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 8/31/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct TrendingView: View {
    @ObservedObject var viewModel = TrendingViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Trending Posts Section
                    Text("Trending Posts")
                        //.font(.headline)
                        .font(.system(.headline, design: .monospaced))
                        .padding(.horizontal)
                    
                    ForEach(viewModel.trendingPosts) { post in
                        TrendingPostView(trendPost: post)
                            .padding(.horizontal)
                    }
                    
                    // New Users Section
                    Text("New Users")
                        //.font(.headline)
                        .font(.system(.headline, design: .monospaced))
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    ForEach(viewModel.newUsers) { user in
                        UserView(user: user)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 10) // Add some top padding for the VStack
                .frame(maxWidth: .infinity, alignment: .leading) // Ensure the VStack takes the full width and left-aligns content
            }
        }
    }
}

struct UserView: View {
    var user: User
    
    @State private var isFollowing: Bool = false
    @State private var followersCount: Int = 0
    
    var body: some View {
        HStack {
            ProfileImageView(imageUrl: user.imageUrl ?? "", size: 35, strokeColor: .secondary, strokeWidth: 1)
            
            VStack(alignment: .leading, spacing: 2) { // Align text to leading and add spacing
                Text(user.name ?? "")
                    .font(.system(.callout, design: .rounded))
                
                Text("Followers \(followersCount)")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                if isFollowing {
                    unfollowUser()
                } else {
                    followUser()
                }
            }) {
                Text(isFollowing ? "Unfollow" : "Follow")
                    .font(.system(.callout, design: .rounded))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isFollowing ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
        }
        .padding(.vertical, 5)
        .onAppear {
            checkFollowStatus()
            fetchFollowersCount()
        }
    }
    
    private func checkFollowStatus() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let docRef = db.collection(Consts.USER_NODE).document(user.id ?? "")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data() {
                    if let followers = data["followers"] as? [String], followers.contains(currentUserUid) {
                        self.isFollowing = true
                    } else {
                        self.isFollowing = false
                    }
                }
            }
        }
    }
    
    private func fetchFollowersCount() {
        let db = Firestore.firestore()
        let docRef = db.collection(Consts.USER_NODE).document(user.id ?? "")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data() {
                    self.followersCount = (data["followers"] as? [String])?.count ?? 0
                }
            }
        }
    }
    
    private func followUser() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection(Consts.USER_NODE).document(user.id ?? "")
        
        // Add current user to following list of the user
        userRef.updateData([
            "followers": FieldValue.arrayUnion([currentUserUid])
        ])
        
        // Add the user to the current user's following list
        let currentUserRef = db.collection(Consts.USER_NODE).document(currentUserUid)
        currentUserRef.updateData([
            "following": FieldValue.arrayUnion([user.id ?? ""])
        ])
        
        self.isFollowing = true
        self.followersCount += 1
    }
    
    private func unfollowUser() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection(Consts.USER_NODE).document(user.id ?? "")
        
        // Remove current user from following list of the user
        userRef.updateData([
            "followers": FieldValue.arrayRemove([currentUserUid])
        ])
        
        // Remove the user from the current user's following list
        let currentUserRef = db.collection(Consts.USER_NODE).document(currentUserUid)
        currentUserRef.updateData([
            "following": FieldValue.arrayRemove([user.id ?? ""])
        ])
        
        self.isFollowing = false
        if self.followersCount > 0 {
            self.followersCount -= 1
        }
    }
}

#Preview {
    TrendingView()
}
