    //
    //  PostView.swift
    //  AMXSFamilyZone
    //
    //  Created by Andrew Stephens on 6/28/24.
    //

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import LinkPreview

struct PostView: View {
    var post: Post
    @State private var showEditDialog = false
    @State private var editText = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        
        ScrollView{
            VStack(alignment: .leading, spacing: 8) {
                
                // Post Image
                PostImageView(imageUrl: post.imageUrl)
                
                // Post Text
                PostTextView(text: post.text, color: .primary, textSize: 15).padding(.top, 5)
                
                // If post contains a link, uses LinkPreview to show/handle URL
                // source: https://github.com/NuPlay/LinkPreview
                if let postLink = post.link, !postLink.isEmpty {
                    LinkPreview(url: URL(string: postLink))
                }
                
                
                // Post Author - Using ZStack to keep text aligned correctly
                if let author = post.user?.name {
                    ZStack(alignment: .leading) {
                        // Invisible background to prevent layout changes
                        Color.clear
                            .frame(height: 20) // Adjust the height to match the text height

                        // Navigation link on top of the transparent background
                        NavigationLink(destination: UserProfileView(userId: post.creatorId!)) {
                            PostTextView(text: "Posted By \(author)", color: .blue, textSize: 13)
                        }
                    }
                }
                
                
                // Post Timestamp
                PostTextView(text: post.getTimeStamp(), color: .secondary, textSize: 11)
                
                // Action Buttons
                HStack {
                    // Vertical Menu Options
                    HStack {
                        Menu {
                            if post.creatorId == Auth.auth().currentUser?.uid {
                                // Edit Post Button
                                Button(action: { editText = post.text; showEditDialog = true }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                // Delete Post Button
                                Button(action: {
                                    deletePost(postId: post.id!)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            } else {
                                // Report post options for other users
                                Button(action: {
                                    reportPost(postId: post.id!, reason: "This is inappropriate")
                                }) {
                                    Label("This is inappropriate", systemImage: "flag")
                                }
                                
                                Button(action: {
                                    reportPost(postId: post.id!, reason: "This is spam")
                                }) {
                                    Label("This is spam", systemImage: "flag")
                                }
                                
                                Button(action: {
                                    reportPost(postId: post.id!, reason: "It made me uncomfortable")
                                }) {
                                    Label("It made me uncomfortable", systemImage: "flag")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                //.font(.title2) // Use a consistent font size
                                .foregroundColor(.primary) // Ensure the color matches your theme
                                .padding()
                            Text("Options")
                                .font(.custom("Alata-Bold", size: 16))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.leading, 8)
                    .sheet(isPresented: $showEditDialog) {
                        EditPostView(postId: post.id!, originalText: post.text)
                            .presentationDetents([.medium])
                    }
                    
                    Spacer()
                    
                    // Share Text
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                            .font(.custom("Alata-Bold", size: 16))
                            .onTapGesture {
                                sharePost(post: post)
                            }
                    }
                    
                    Spacer()
                    
                    // Bookmark Icon
                    HStack {
                        Image(systemName: "bookmark")
                        Text("Bookmark")
                            .font(.custom("Alata-Bold", size: 16))
                            .onTapGesture {saveImage()}
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)
                .padding(.bottom, 14)
                .padding(.horizontal, 8)
                
                // Separator Line
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal, 8)
            }
        }

        .cornerRadius(12)
        .shadow(radius: 8)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Image Saved"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        
    } // end of body
    
    // Shares Post Image (Firebase URL) and Text
    func sharePost(post: Post) {
        var items: [Any] = []
        
        // Add the image URL if it exists
        if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
            items.append(url)
        }
        
        // Add the post text
        items.append(post.text)
        
        // Get the current window scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        // Create the activity view controller with the items to share
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Exclude certain types of activity if needed
        activityViewController.excludedActivityTypes = [.assignToContact, .saveToCameraRoll]
        
        // Present the activity view controller
        window.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    // Function to save the image to the device
    func saveImage() {
        guard let imageUrl = post.imageUrl, let url = URL(string: imageUrl) else {
            print("Image URL is invalid")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to download image: \(error?.localizedDescription ?? "Unknown error")")
                alertMessage = "Failed to save the image. Please try again."
                showAlert = true
                return
            }
            
            guard let uiImage = UIImage(data: data) else {
                print("Failed to convert data to image")
                alertMessage = "Failed to convert the image. Please try again."
                showAlert = true
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            alertMessage = "The image has been saved to your Photos."
            showAlert = true
        }.resume()
    }
    
    // Deletes post from Firebase
    func deletePost(postId: String) {
        let firestore = Firestore.firestore()
        let documentReference = firestore.collection(Consts.POST_NODE).document(postId)
        
        documentReference.getDocument() { documentSnapshot, error in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                print("Document does not exist")
                return
            }
            
            if let existingPost = try? documentSnapshot.data(as: Post.self),
               existingPost.creatorId == Auth.auth().currentUser?.uid {
                documentReference.delete { error in
                    if let error = error {
                        print("Error deleting post: \(error)")
                    } else {
                        print("Post deleted successfully")
                    }
                }
            } else {
                print("You can only delete your own posts!")
            }
        }
    }
    
    // Function to report posts
    func reportPost(postId: String, reason: String) {
        let firestore = Firestore.firestore()
        let reportReference = firestore.collection(Consts.REPORTS_NODE).document()
        
        let reportData: [String: Any] = [
            "postId": postId,
            "reporterId": Auth.auth().currentUser?.uid ?? "",
            "reason": reason,
            "timestamp": Timestamp()
        ]
        
        reportReference.setData(reportData) { error in
            if let error = error {
                print("Error reporting post: \(error)")
            } else {
                print("Post reported successfully for reason: \(reason)")
            }
        }
    }
}

struct EditPostView: View {
    var postId: String
    @State var originalText: String
    @State private var newText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            TextField("Edit Post", text: $newText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                updatePost(postId: postId, newText: newText)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Update Post")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            Spacer()
                .onAppear {
                    newText = originalText
                }
        } // end of VStack
    } // end of body view
    
        // Function for updating text of post, new text gets saved to Firebase
    func updatePost(postId: String, newText: String) {
        let firestore = Firestore.firestore()
        let documentReference = firestore.collection(Consts.POST_NODE).document(postId)
        
        documentReference.getDocument() { documentSnapshot, error in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                print("Document does not exist")
                return
            }
            
            if let existingPost = try? documentSnapshot.data(as: Post.self),
               existingPost.creatorId == Auth.auth().currentUser?.uid {
                documentReference.updateData(["text": newText]) { error in
                    if let error = error {
                        print("Error updating post: \(error)")
                    } else {
                        print("Post updated successfully")
                    }
                }
            } else {
                print("You can only edit your own posts!")
            }
        }
    }
} // end of editpostview
