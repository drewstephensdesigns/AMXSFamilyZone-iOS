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
    @State private var isFollowing: Bool = false
    @State private var isCurrentUserProfile: Bool = false // Track if the profile is the current user's
    @State private var navigateToEditProfile: Bool = false // Navigation trigger for EditProfileView

    var body: some View {
        ScrollView {
            VStack {
                
                // User Image and Follows
                HStack {
                    ProfileImageView(
                        imageUrl: profileImageUrl,
                        size: 80,
                        strokeColor: .blue,
                        strokeWidth: 1
                    )
                    
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
                    
                    Spacer()
                    
                    Button(action: {
                        if isCurrentUserProfile {
                            navigateToEditProfile = true
                        } else {
                            if isFollowing {
                                unfollowUser()
                            } else {
                                followUser()
                            }
                        }
                    }) {
                        Text(isCurrentUserProfile ? "Edit Profile" : (isFollowing ? "Unfollow" : "Follow"))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(isCurrentUserProfile ? Color.gray : (isFollowing ? Color.red : Color.blue))
                            .cornerRadius(20)
                    }
                    .padding(.trailing, 10)
                    .background(
                        NavigationLink(destination: EditProfileView(
                            name: self.name,
                            bio: self.bio,
                            website: self.website,
                            profileImageUrl: self.profileImageUrl)) {
                            EmptyView()
                        }
                        .hidden()
                    )
                }
                .padding(.top, 20)
                
                // Username, Bio, URL
                VStack(alignment: .leading) {
                    Text(self.name)
                        .font(.custom("Futura", size: 16))
                        .padding(.top, 6)
                        .padding(.horizontal, 10)
                    
                    Text(self.bio)
                       // .font(.footnote)
                        .font(.system(.callout, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.top, 6)
                        .lineLimit(4)
                    
                    if !self.website.isEmpty {
                        Text(self.website)
                            .font(.footnote)
                            .textCase(.lowercase)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.top, 6)
                            .onTapGesture {
                                if let encodedUrl = self.website.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                   let url = URL(string: encodedUrl) {
                                    UIApplication.shared.open(url, options: [:]) { success in
                                        if !success {
                                            print("Failed to open URL: \(self.website)")
                                        }
                                    }
                                } else {
                                    print("Invalid URL: \(self.website)")
                                }
                            }
                    }
                    Divider()
                        .background(Color.secondary)
                        .padding(.top, 5)
                }
                .padding(.horizontal, 10)
                
                    // Grid of posts
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ],
                        spacing: 8 // Adjust spacing between rows
                    ) {
                        ForEach(posts, id: \.self) { postUrl in
                            if let url = URL(string: postUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 150)
                                        .clipped()
                                        //.onTapGesture {
                                        //    selectedImageUrl = postUrl
                                        //    print("Fetched image URL: \(selectedImageUrl ?? "No URL")")
                                       // }
                                } placeholder: {
                                    Color.gray
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 5) // Reduce padding to bring items closer to the edges
            }
        }
        .navigationTitle(self.$name)
        .onAppear {
            fetchData()
            checkIfFollowing()
            checkIfCurrentUserProfile()
        }
    }

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
    
    private func checkIfCurrentUserProfile() {
        if let currentUserUid = Auth.auth().currentUser?.uid {
            self.isCurrentUserProfile = (currentUserUid == userId)
        }
    }

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

struct UserProfile_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(userId: "exampleUser")
    }
}
