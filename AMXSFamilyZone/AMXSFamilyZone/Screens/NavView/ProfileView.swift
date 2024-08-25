    //
    //  ProfileView.swift
    //  AMXSFamilyZone
    //
    //  Created by Andrew Stephens on 6/28/24.
    //

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @State var contentMode = ContentMode.fit
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var website: String = ""
    @State private var profileImageUrl: String = ""
    @State private var posts: [String] = []
    @State private var selectedImageUrl: String? = nil
    @State private var isImagePresented: Bool = false
    @State private var followersCount: Int = 0
    @State private var followingCount: Int = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
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
                        
                        NavigationLink(destination: EditProfileView(name: name, bio: bio, website: website, profileImageUrl: profileImageUrl)) {
                            Text("Edit Profile")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 20)
                    
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
                                        //.aspectRatio(contentMode: .fill)
                                        .aspectRatio(contentMode: contentMode)
                                        .frame(width: 150, height: 150)
                                        .clipped()
                                        .onTapGesture {
                                            selectedImageUrl = postUrl
                                           // isImagePresented = true
                                            print("Fetched image URL: \(selectedImageUrl ?? "No URL")")
                                        }
                                } placeholder: {
                                    Color.gray
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                fetchData()
            }
            //.sheet(isPresented: $isImagePresented) {
            //    ImageViewer(imageUrl: selectedImageUrl)
           // }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Add this line
    }
    
    private func fetchData() {
        let db = Firestore.firestore()
        
        if let userId = Auth.auth().currentUser?.uid {
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
            
                // Fetch posts
            db.collection(Consts.POST_NODE).whereField("creatorId", isEqualTo: userId).getDocuments { (snapshot, error) in
                if let snapshot = snapshot {
                    self.posts = snapshot.documents.compactMap { document in
                        let imageUrl = document.data()["imageUrl"] as? String
                        print("Fetched image URL: \(imageUrl ?? "No URL")")
                        return imageUrl
                    }
                }
            }
        }
    }
}

struct ImageViewer: View {
    var imageUrl: String?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
            
            if let url = URL(string: imageUrl ?? "") {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } placeholder: {
                    ProgressView()
                }
            }
            
            VStack {
                Spacer()
                Button(action: {
                    UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                }) {
                    Text("Close")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.bottom, 30)
                }
            }
        }
    }
}
