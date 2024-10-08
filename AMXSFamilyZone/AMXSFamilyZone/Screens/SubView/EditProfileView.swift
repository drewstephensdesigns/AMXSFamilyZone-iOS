//
//  EditProfileView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/28/24.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct EditProfileView: View {
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var newUserName: String
    @State private var newBio: String
    @State private var newLink: String
    @State private var profileImageUrl: String

    init(name: String, bio: String, website: String, profileImageUrl: String) {
        _newUserName = State(initialValue: name)
        _newBio = State(initialValue: bio)
        _newLink = State(initialValue: website)
        _profileImageUrl = State(initialValue: profileImageUrl)
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)

                if let url = URL(string: profileImageUrl), image == nil {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .clipShape(Circle())
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    } placeholder: {
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                } else if let image = image {
                    image
                        .resizable()
                        .clipShape(Circle())
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
            }

            Button(action: {
                self.showingImagePicker = true
            }) {
                Text("Change Picture")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.primary, Color.purple]), startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                TextField("Name", text: $newUserName)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                
                TextField("Bio", text: $newBio)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                
                TextField("Link", text: $newLink)
                    .autocapitalization(.none)
                    .keyboardType(.URL)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
            }
            .padding(.horizontal)
            
            Button(action: {
                updateUserProfile()
            }) {
                Text("Update Profile")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 30)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
        .padding()
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }

    func updateUserProfile() {
        guard let currentUser = Auth.auth().currentUser else { return }

        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(currentUser.uid)

        var updateData: [String: Any] = [
            "name": newUserName,
            "bio": newBio,
            "link": newLink,
        ]

        if let inputImage = inputImage {
            let storageRef = Storage.storage().reference().child("Images/\(currentUser.uid)")

            guard let imageData = inputImage.jpegData(compressionQuality: 0.5) else { return }

            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            storageRef.putData(imageData, metadata: metadata) { metadata, error in
                guard let _ = metadata else {
                    print("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                storageRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }

                    updateData["profileImageUrl"] = downloadURL.absoluteString

                    userRef.updateData(updateData) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
            }
        } else {
            userRef.updateData(updateData) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(name: "John Doe", bio: "This is the bio", website: "www.example.com", profileImageUrl: "https://picsum.photos/id/27/500/500")
    }
}
