//
//  UserProfileView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 7/14/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct UserProfileView: View {
    var userId: String
    
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var website: String = ""
    @State private var profileImageUrl: String = ""
    @State private var posts: [String] = []
    @State private var selectedImageUrl: String? = nil
    @State private var isImagePresented: Bool = false
    @State private var followersCount: Int = 0
    @State private var followingCount: Int = 0
    @State private var isFollowing: Bool = false // Track if current user is following this user
    
    var body: some View {
        ScrollView {
            VStack {
                // Profile Header
                HStack {
                    let imageUrl = profileImageUrl.isEmpty ? Consts.DEFAULT_USER_IMAGE : profileImageUrl
                    if let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue, lineWidth: 1))
                                .padding(.leading, 20)
                        } placeholder: {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue, lineWidth: 1))
                                .padding(.leading, 20)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("\(followersCount)")
                                .foregroundColor(.blue)
                                .font(.headline)
                            Text("Followers")
                                .font(.headline)
                        }
                        HStack {
                            Text("\(followingCount)")
                                .foregroundColor(.blue)
                                .font(.headline)
                            Text("Following")
                                .font(.headline)
                        }
                        HStack {
                            Text("\(posts.count)")
                                .foregroundColor(.blue)
                                .font(.headline)
                            Text("Posts")
                                .font(.headline)
                        }
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                // User Details
                VStack(alignment: .leading) {
                    Text(self.name)
                        .font(.title)
                        .bold()
                        .padding(.horizontal, 8)
                    Text(self.bio)
                        .font(.body)
                        .padding(.horizontal, 8)
                        .padding(.top, 6)
                        .lineLimit(4)
                    
                    if !self.website.isEmpty {
                        Text(self.website)
                            .font(.callout)
                            .textCase(.lowercase)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.top, 6)
                            .onTapGesture {
                                if let url = URL(string: website) {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    Divider()
                        .background(Color.blue)
                        .padding(.top, 5)
                }
                .padding(.horizontal, 10)
                
                // Grid of posts
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(posts, id: \.self) { postUrl in
                        if let url = URL(string: postUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .onTapGesture {
                                        selectedImageUrl = postUrl
                                        isImagePresented = true
                                    }
                            } placeholder: {
                                Color.gray
                                    .frame(width: 100, height: 100)
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                
                // Follow/Unfollow Button
                HStack {
                    Spacer()
                    if isFollowing {
                        Button(action: {
                            unfollowUser()
                        }) {
                            Text("Unfollow")
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        }
                    } else {
                        Button(action: {
                            followUser()
                        }) {
                            Text("Follow")
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Profile")
        .onAppear {
            fetchData()
            checkIfFollowing()
        }
        .sheet(isPresented: $isImagePresented) {
            if let selectedImageUrl = selectedImageUrl, let url = URL(string: selectedImageUrl) {
                VStack {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } placeholder: {
                        Color.gray
                    }
                    Button("Close") {
                        isImagePresented = false
                    }
                    .padding()
                }
            }
        }
    }
    
    // Function to fetch user data from Firestore
    private func fetchData() {
        let db = Firestore.firestore()
        
        // Fetch user profile data
        let docRef = db.collection(Consts.USER_NODE).document(userId)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data() {
                    DispatchQueue.main.async {
                        self.name = data["name"] as? String ?? ""
                        self.bio = data["bio"] as? String ?? ""
                        self.website = data["link"] as? String ?? ""
                        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
                        self.followersCount = (data["followers"] as? [String])?.count ?? 0
                        self.followingCount = (data["following"] as? [String])?.count ?? 0
                    }
                }
            }
        }
        
        // Fetch user's posts
        db.collection(Consts.POST_NODE)
            .whereField("creatorId", isEqualTo: userId)
            .getDocuments { (snapshot, error) in
                if let snapshot = snapshot {
                    self.posts = snapshot.documents.compactMap { document in
                        document.data()["imageUrl"] as? String
                    }
                }
            }
    }
    
    // Function to check if current user is following this user
    private func checkIfFollowing() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let docRef = db.collection(Consts.USER_NODE).document(userId)
        
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
    
    // Function to follow the user
    private func followUser() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection(Consts.USER_NODE).document(userId)
        
        // Add current user to following list of the user
        userRef.updateData([
            "followers": FieldValue.arrayUnion([currentUserUid])
        ])
        
        // Add the user to the current user's following list
        let currentUserRef = db.collection(Consts.USER_NODE).document(currentUserUid)
        currentUserRef.updateData([
            "following": FieldValue.arrayUnion([userId])
        ])
        
        self.isFollowing = true
        self.followersCount += 1
    }
    
    // Function to unfollow the user
    private func unfollowUser() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection(Consts.USER_NODE).document(userId)
        
        // Remove current user from following list of the user
        userRef.updateData([
            "followers": FieldValue.arrayRemove([currentUserUid])
        ])
        
        // Remove the user from the current user's following list
        let currentUserRef = db.collection(Consts.USER_NODE).document(currentUserUid)
        currentUserRef.updateData([
            "following": FieldValue.arrayRemove([userId])
        ])
        
        self.isFollowing = false
        if self.followersCount > 0 {
            self.followersCount -= 1
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(userId: "exampleUserId")
    }
}
