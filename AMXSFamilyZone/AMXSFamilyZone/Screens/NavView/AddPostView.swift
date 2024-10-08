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
import LinkPreview

struct AddPostView: View {
    @State private var image: UIImage? = nil
    @State private var postText: String = ""
    @State private var linkText: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    @State private var isImagePickerPresented = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    @State private var showLinkField = false  // State variable to show the link field
    
        // Alert Message
    @State private var showAlert = false  // New state variable to control the alert
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var attributedText: AttributedString = ""
    @State private var size: CGFloat = 350
    
    let maxLines: Int = 5
    let characterLimitPerLine = 40
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
                // OPSEC Notice
            Text("Please Remember OPSEC When Posting")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)
            
                // Multi-line text input using TextEditor for post description
            TextEditor(text: Binding(
                get: { self.postText },
                set: { newValue in
                    let lines = newValue.split(separator: "\n")
                    if lines.count <= maxLines && newValue.count <= (maxLines * characterLimitPerLine) {
                        self.postText = newValue
                    } else {
                        let limitedText = newValue.prefix(maxLines * characterLimitPerLine)
                        self.postText = String(limitedText)
                    }
                })
            )
            .frame(minHeight: 80, maxHeight: 100)
            .padding(8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal)
            
                // Conditionally show link TextField when the button is clicked
            if showLinkField {
                TextField("Enter link", text: $linkText)
                    .onChange(of: linkText) {
                        linkText = linkText.lowercased() // Convert the text to lowercase
                    }
                    .padding()
                    .frame(height: 40)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .font(.custom("Alata", size: 16))
                    .padding(.horizontal)
                
                // source: https://github.com/NuPlay/LinkPreview
                // Preview with Link's meta information.
                LinkPreview(url: URL(string: linkText))
                    .backgroundColor(.blue)
                                  .primaryFontColor(.white)
                                  .secondaryFontColor(.white.opacity(0.6))
                                  .titleLineLimit(3)
                                  .frame(width: size, alignment: .center)
            }
            
                // Action Icons
            HStack(spacing: 18) {
                    // Image Icon
                Button(action: {
                        // Handle image selection
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
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.gray)
                    }
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: $image)
                        .onDisappear {
                            print("Selected image: \(String(describing: image))")
                        }
                }
                
                    // Link Icon
                Button(action: {
                        // Toggle the visibility of the link TextField
                    withAnimation {
                        showLinkField.toggle()
                    }
                }) {
                    Image(systemName: "link")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .rotationEffect(.degrees(45))
                        .foregroundColor(.gray)
                }
                
                    // Take Photo Icon
                Button(action: {
                        // Handle taking a photo
                    imagePickerSourceType = .camera
                    isImagePickerPresented.toggle()
                }) {
                    Image(systemName: "camera")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
            
                // Post Image
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280)
                    .clipped()
            }
            
                // Post Button
            Button(action: {
                // Check if image is added but post text is empty
                if image != nil && postText.isEmpty {
                    // Trigger the alert only if post text is empty
                    alertTitle = "Missing Post Text"
                    alertMessage = "Please add text to your post before submitting."
                    showAlert = true
                } else {
                    // Proceed with submission if postText is not empty
                    addPost()
                    print("Post submitted")
                }
            }) {
                Text("Post")
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        // Reset alert state after dismissal
                        showAlert = false
                    }
                )
            }
            
            Spacer()
        }
        .padding(16)
        .sheet(isPresented: $isImagePickerPresented) {
            CameraImagePicker(selectedImage: $selectedImage, sourceType: imagePickerSourceType)
        }
    }
    
    // Future function for Hashtags
    private func updateHashtagColors(){
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
    
    // Adds post to Firebase
    private func addPost(){
        guard let currentUser = Auth.auth().currentUser else {return}
        let firestore = Firestore.firestore()
        
        firestore.collection(Consts.USER_NODE).document(currentUser.uid).getDocument{document, error in
            if error != nil {
                self.alertTitle = "Error"
                self.alertMessage = "Error retrieving user document: (error.localizedDescription)"
                self.showAlert = true
            }
            
            guard let document = document, document.exists else {
                self.alertTitle = "Error"
                self.alertMessage = "User not found"
                self.showAlert = true
                return
            }
            
            do {
                let user = try document.data(as: User?.self)
                if let user = user {
                    if let image = self.image {
                        self.uploadImageAndPost(image: image, text: self.postText, user: user, link: self.linkText)
                    } else {
                        self.createPostWithoutImage(text: self.postText, link: self.linkText, user: user, creatorId: currentUser.uid)
                    }
                } else {
                    self.alertTitle = "Error"
                    self.alertMessage = "User data decoding failed"
                    self.showAlert = true
                }
            } catch {
                self.alertTitle = "Error"
                self.alertMessage = "User data decoding failed: \(error.localizedDescription)"
                self.showAlert = true
            }
        }
    }
    
    // Uploads image to Firebase Storage, compresses the image to JPG to save storage space
    private func uploadImageAndPost(image: UIImage, text: String, user: User?, link: String){
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
        self.alertTitle = "Error"
        self.alertMessage = "Image data conversion failed"
        self.showAlert = true
        return
    }

        let storageRef = Storage.storage().reference().child(Consts.IMAGES_NODE).child("\(UUID().uuidString).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                self.alertTitle = "Error"
                self.alertMessage = "Image upload failed: \(error.localizedDescription)"
                self.showAlert = true
                return
            }

            storageRef.downloadURL { url, error in
                if let url = url {
                    self.createPost(text: text, link: linkText, imageUrl: url.absoluteString, user: user, creatorId: Auth.auth().currentUser?.uid ?? "")
                } else {
                    self.alertTitle = "Error"
                    self.alertMessage = "Image URL retrieval failed"
                    self.showAlert = true
                }
            }
        }
    }
    
    
    private func createPostWithoutImage(text: String, link: String, user: User?, creatorId: String){
        createPost(text: text, link: link, imageUrl: nil, user: user, creatorId: creatorId)
    }
    
    // Function handles the creation of a post in Firestore, verifies user data, and manages success or failure with appropriate alerts.
    private func createPost(text: String, link: String?, imageUrl: String?, user: User?, creatorId: String){
        
        guard let user = user else {
        self.alertTitle = "Error"
        self.alertMessage = "User data missing"
        self.showAlert = true
        return
    }

        let currentTime = Date().timeIntervalSince1970
        var post = Post(
            text: text,
            link: link,
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
                        self.showAlert = true
                    } else {
                        // Update the post's id with the generated document ID
                        if let documentId = ref?.documentID {
                            post.id = documentId
                            self.alertTitle = "Success"
                            self.alertMessage = "Posted successfully!"
                            self.showAlert = true
                            self.postText = ""
                            self.image = nil
                        }
                    }
            }
            } catch let error {
                self.alertTitle = "Error"
                self.alertMessage = "Error writing post to Firestore: \(error.localizedDescription)"
                self.showAlert = true
            }
    }
}



extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
}

#Preview{
    AddPostView()
}

