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
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var attributedText: AttributedString = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
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
                    .onChange(of: postText) { oldValue, newValue in
                        updateHashtagColors()
                    }

                Button(action: {
                    UIApplication.shared.endEditing() // Dismiss the keyboard
                    if postText.isEmpty {
                        alertTitle = "Error"
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
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    if alertMessage == "Posted successfully!" {
                        dismiss()
                    }
                })
            }
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

        firestore.collection(Consts.USER_NODE).document(currentUser.uid).getDocument { document, error in
            if let error = error {
                self.alertTitle = "Error"
                self.alertMessage = "Error retrieving user document: \(error.localizedDescription)"
                self.showingAlert = true
                return
            }

            guard let document = document, document.exists else {
                self.alertTitle = "Error"
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
                        self.createPostWithoutImage(text: self.postText, user: user, creatorId: currentUser.uid)
                    }
                } else {
                    self.alertTitle = "Error"
                    self.alertMessage = "User data decoding failed"
                    self.showingAlert = true
                }
            } catch {
                self.alertTitle = "Error"
                self.alertMessage = "User data decoding failed: \(error.localizedDescription)"
                self.showingAlert = true
            }
        }
    }

    private func uploadImageAndPost(image: UIImage, text: String, user: User?) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            self.alertTitle = "Error"
            self.alertMessage = "Image data conversion failed"
            self.showingAlert = true
            return
        }

        let storageRef = Storage.storage().reference().child(Consts.IMAGES_NODE).child("\(UUID().uuidString).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                self.alertTitle = "Error"
                self.alertMessage = "Image upload failed: \(error.localizedDescription)"
                self.showingAlert = true
                return
            }

            storageRef.downloadURL { url, error in
                if let url = url {
                    self.createPost(text: text, imageUrl: url.absoluteString, user: user, creatorId: Auth.auth().currentUser?.uid ?? "")
                } else {
                    self.alertTitle = "Error"
                    self.alertMessage = "Image URL retrieval failed"
                    self.showingAlert = true
                }
            }
        }
    }

    private func createPostWithoutImage(text: String, user: User?, creatorId: String) {
        createPost(text: text, imageUrl: nil, user: user, creatorId: creatorId)
    }

    private func createPost(text: String, imageUrl: String?, user: User?, creatorId: String) {
        guard let user = user else {
            self.alertTitle = "Error"
            self.alertMessage = "User data missing"
            self.showingAlert = true
            return
        }

        let currentTime = Date().timeIntervalSince1970
        var post = Post(
            text: text,
            imageUrl: imageUrl,
            user: user,
            creatorId: creatorId,
            time: currentTime)

        let firestore = Firestore.firestore()
        var ref: DocumentReference? = nil

        do {
            ref = try firestore.collection(Consts.POST_NODE).addDocument(from: post) { error in
                if let error = error {
                    self.alertTitle = "Error"
                    self.alertMessage = "Error occurred: \(error.localizedDescription)"
                    self.showingAlert = true
                } else {
                    // Update the post's id with the generated document ID
                    if let documentId = ref?.documentID {
                        post.id = documentId
                        self.alertTitle = "Success"
                        self.alertMessage = "Posted successfully!"
                        self.showingAlert = true
                        self.postText = ""
                        self.image = nil
                    }
                }
            }
        } catch let error {
            self.alertTitle = "Error"
            self.alertMessage = "Error writing post to Firestore: \(error.localizedDescription)"
            self.showingAlert = true
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
