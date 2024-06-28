//
//  AddPostView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/28/24.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct AddPostView: View {
    @State private var image: UIImage? = nil
    @State private var postText: String = ""
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var attributedText: AttributedString = ""
    @State private var navigateToHome = false // Add this line
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Text("Please Remember OPSEC When Posting")
                    .font(.headline)
                    .bold()
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                Spacer()

                Button(action: {
                    showingImagePicker.toggle()
                }) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 75)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .shadow(radius: 4)
                            .padding(.bottom, 10)
                    } else {
                        Image(systemName: "photo.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 75)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .shadow(radius: 4)
                            .padding(.bottom, 10)
                    }
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: $image)
                        .onDisappear {
                            print("Selected image: \(String(describing: image))")
                        }
                }

                Spacer()
                Text("What's on Your Mind? \n Post a Picture, Text, or Both")
                    .font(.subheadline)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)

                TextField("Write a caption", text: $postText, onEditingChanged: { _ in
                    updateHashtagColors()
                })
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                    .padding(.bottom, 16)
                    .onChange(of: postText) { _ in
                        updateHashtagColors()
                    }

                Button(action: {
                    UIApplication.shared.endEditing() // Dismiss the keyboard
                    if postText.isEmpty {
                        alertMessage = "Description can't be empty"
                        showingAlert = true
                    } else {
                        addPost()
                    }
                }) {
                    Text("Post")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .cornerRadius(10)
                }
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    if alertMessage == "Posted successfully!" {
                        navigateToHome = true
                    }
                })
            }
            .background(
                NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }

    private func updateHashtagColors() {
        var attributedString = AttributedString(postText)
        let pattern = "#(\\w+)"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(location: 0, length: postText.utf16.count)
            let matches = regex.matches(in: postText, range: range)
            for match in matches {
                if let stringRange = Range(match.range, in: postText),
                   let attributedRange = Range(stringRange, in: attributedString) {
                    attributedString[attributedRange].foregroundColor = Color.blue
                }
            }
        }
        attributedText = attributedString
    }

    private func addPost() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let firestore = Firestore.firestore()

        firestore.collection("Users").document(currentUser.uid).getDocument { document, error in
            if let error = error {
                self.alertMessage = "Error retrieving user document: \(error.localizedDescription)"
                self.showingAlert = true
                return
            }

            guard let document = document, document.exists else {
                self.alertMessage = "User not found"
                self.showingAlert = true
                return
            }

            do {
                let user = try document.data(as: User?.self)
                if let user = user {
                    if let image = self.image {
                        self.uploadImageAndPost(image: image, text: self.postText, user: user)
                    } else {
                        self.createPostWithoutImage(text: self.postText, user: user, creatorID: currentUser.uid)
                    }
                } else {
                    self.alertMessage = "User data decoding failed"
                    self.showingAlert = true
                }
            } catch {
                self.alertMessage = "User data decoding failed: \(error.localizedDescription)"
                self.showingAlert = true
            }
        }
    }

    private func uploadImageAndPost(image: UIImage, text: String, user: User?) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            self.alertMessage = "Image data conversion failed"
            self.showingAlert = true
            return
        }

        let storageRef = Storage.storage().reference().child("Images").child("\(UUID().uuidString).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                self.alertMessage = "Image upload failed: \(error.localizedDescription)"
                self.showingAlert = true
                return
            }

            storageRef.downloadURL { url, error in
                if let url = url {
                    self.createPost(text: text, imageUrl: url.absoluteString, user: user, creatorID: Auth.auth().currentUser?.uid ?? "")
                } else {
                    self.alertMessage = "Image URL retrieval failed"
                    self.showingAlert = true
                }
            }
        }
    }

    private func createPostWithoutImage(text: String, user: User?, creatorID: String) {
        createPost(text: text, imageUrl: nil, user: user, creatorID: creatorID)
    }

    private func createPost(text: String, imageUrl: String?, user: User?, creatorID: String) {
        guard let user = user else {
            self.alertMessage = "User data missing"
            self.showingAlert = true
            return
        }

        let currentTime = Date().timeIntervalSince1970
        let post = Post(
            text: text,
            imageUrl: imageUrl,
            user: user,
            creatorID: creatorID,
            time: currentTime)
        print("Post data: \(post.dictionary)") // Debugging print

        let firestore = Firestore.firestore()
        firestore.collection("Post").addDocument(data: post.dictionary) { error in
            if let error = error {
                self.alertMessage = "Error occurred: \(error.localizedDescription)"
                self.showingAlert = true
            } else {
                self.alertMessage = "Posted successfully!"
                self.showingAlert = true
                self.postText = ""
                self.image = nil
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct AddPostView_Previews: PreviewProvider {
    static var previews: some View {
        AddPostView()
    }
}
