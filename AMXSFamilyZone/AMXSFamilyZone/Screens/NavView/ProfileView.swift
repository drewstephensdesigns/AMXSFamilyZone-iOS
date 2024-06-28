//
//  ProfileView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/28/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var name: String = "" // State variables to store fetched data
    @State private var bio: String = ""
    @State private var website: String = ""
    @State private var profileImageUrl: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        // Profile Image
                        if let url = URL(string: profileImageUrl) {
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
                                // Number of Followers
                                Text("45")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                                Text("Followers")
                                    .font(.headline)
                            }
                            HStack {
                                // Number of Followings
                                Text("55")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                                Text("Following")
                                    .font(.headline)
                            }
                            HStack {
                                // Total Posts
                                Text("0")
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
                        Text(self.name) // Use fetched data here
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
                                    // Handle Link Tap
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
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                fetchData() // Fetch data when the view appears
            }
        }
    }

    // Function to fetch data from Firebase
    private func fetchData() {
        // Assuming you have a reference to your Firestore database
        let db = Firestore.firestore()

        // Assuming you have a 'users' collection and the user's UID
        if let userId = Auth.auth().currentUser?.uid {
            // Assuming you have a document with the user's UID as the document ID
            let docRef = db.collection("Users").document(userId)

            // Fetch data
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data() {
                        // Extracting data
                        DispatchQueue.main.async {
                            self.name = data["name"] as? String ?? ""
                            self.bio = data["bio"] as? String ?? ""
                            self.website = data["link"] as? String ?? ""
                            self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
                        }
                        print("Fetched data: \(data)") // Logging fetched data
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
