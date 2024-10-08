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
   
    @State private var userName: String = "johndoedev"
    @State private var name: String = "John Doe"
    @State private var bio: String = "We choose to go to the moon. We choose to go to the moon in this decade and do the other things, not because they are easy, but because they are hard"
    @State private var website: String = "https://johndoe.dev"
    @State private var profileImageUrl: String = "https://picsum.photos/id/237/100/100"
    @State private var posts: [String] = [
        "https://picsum.photos/id/16/500/500",
        "https://picsum.photos/id/37/500/500",
        "https://picsum.photos/id/27/500/500",
        "https://picsum.photos/id/73/500/500",
        "https://picsum.photos/id/255/500/500",
        "https://picsum.photos/id/317/500/500",
        "https://picsum.photos/id/270/500/500",
    ]
    @State private var selectedImageUrl: String? = nil
    @State private var isImagePresented: Bool = false
    @State private var followersCount: Int = 100
    @State private var followingCount: Int = 75
    @State private var imageSize: CGFloat = 90
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Profile Image and Counters
                    HStack {
                        let imageUrl = profileImageUrl.isEmpty ? Consts.DEFAULT_USER_IMAGE : profileImageUrl
                        if let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.blue, lineWidth: 1))
                                    .frame(width: imageSize, height: imageSize)
                                    .padding(.leading, 10)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            imageSize = (imageSize == 80) ? 110 : 80
                                        }
                                    }
                            } placeholder: {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.blue, lineWidth: 1))
                                    .padding(.leading, 10)
                            }
                        }
                        
                            // Followers, Following, Posts
                            HStack {
                                VStack {
                                    Text("Followers")
                                       // .font(.caption)
                                        .font(.custom("Futura", size: 17))
                                        .foregroundColor(.gray)
                                    Text("\(followersCount)")
                                        .font(.subheadline)
                                }
                                .frame(maxWidth: .infinity)

                                VStack {
                                    Text("Following")
                                       // .font(.caption)
                                        .font(.custom("Futura", size: 17))
                                        .foregroundColor(.gray)
                                        .padding(.leading, 5)
                                    Text("\(followingCount)")
                                        .font(.subheadline)
                                        .padding(.leading, 5)
                                        
                                }
                                .frame(maxWidth: .infinity)

                                VStack {
                                    Text("Posts")
                                       // .font(.caption)
                                        .font(.custom("Futura", size: 17))
                                        .foregroundColor(.gray)
                                    Text("\(posts.count)")
                                        .font(.subheadline)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.top, 10)
                        .padding(.leading, 10)
                        
                        Spacer()
                    }
                    .padding(.top, 20)

                    // Name, Bio, and Website
                    VStack(alignment: .leading) {
                        Text(self.name)
                            .font(.custom("Futura", size: 18))
                            .padding(.top, 6)
                            .padding(.horizontal, 10)
                        
                        Text(self.bio)
                            .font(.custom("Cochina", size: 15))
                            .padding(.horizontal, 8)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(6)
                            .padding(.top, 6)
                            .lineLimit(4)
                        
                        if !self.website.isEmpty {
                            HStack {
                                // Icon
                                Image(systemName: "link")
                                    .foregroundColor(.blue)
                                    .font(.subheadline)
                                    .padding(.leading, 6)
                                
                                // URL Text
                                Text(self.website)
                                    .font(.subheadline)
                                    .textCase(.lowercase)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 2)
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
                            .padding(.top, 6)
                        }
                        
                        // Edit Profile Button (moved here)
                        NavigationLink(destination: EditProfileView(name: name, bio: bio, website: website, profileImageUrl: profileImageUrl)) {
                            Text("Edit Profile")
                                .font(.custom("Cochina", size: 16))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 40)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10) // Add some space between the website and button
                        
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
                        spacing: 8
                    ) {
                        ForEach(posts, id: \.self) { postUrl in
                            if let url = URL(string: postUrl) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipped()
                                } placeholder: {
                                    Color.gray
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
            .navigationTitle(self.userName)
            .onAppear {
                //fetchData()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Fetch data function remains unchanged
    private func fetchData() {
        let db = Firestore.firestore()
        
        if let userId = Auth.auth().currentUser?.uid {
            let docRef = db.collection(Consts.USER_NODE).document(userId)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data() {
                        DispatchQueue.main.async {
                            self.name = data["name"] as? String ?? ""
                            self.userName = data["userName"] as? String ?? ""
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


// Not used
// TODO: Allow user to click on an image to see a bigger view
struct ImageViewer: View {
    var imageUrl: String?
    
    @Environment(\.dismiss) var dismiss
    
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
                        //UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                    dismiss()
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

#Preview{
    ProfileView()
}
