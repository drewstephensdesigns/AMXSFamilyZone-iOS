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
        VStack {
            if let url = URL(string: profileImageUrl), image == nil {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 75)
                } placeholder: {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 75)
                }
            } else if let image = image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 75)
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 75)
            }

            Button("Change Picture") {
                self.showingImagePicker = true
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }

            TextField("Name", text: $newUserName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Bio", text: $newBio)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Link", text: $newLink)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textCase(.lowercase)

            Button("Update Profile") {
                updateUserProfile()
            }
            .padding()
        }
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
        EditProfileView(name: "John Doe", bio: "This is the bio", website: "www.example.com", profileImageUrl: "")
    }
}
