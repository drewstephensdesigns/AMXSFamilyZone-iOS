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

struct PostView: View {
    var post: Post
    
    @State private var showEditDialog = false
    @State private var editText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                if let imageUrl = post.imageUrl, !imageUrl.isEmpty {
                    WebImage(url: URL(string: imageUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 350) // Set the height of the image
                        .frame(maxWidth: .infinity, alignment: .center) // Center the image
                        .clipped() // Ensure the image doesn't overflow
                }
            } // end of ZStack
            
            // Text of Post
            Text(post.text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding([.horizontal, .top], 6)
            
            // Author of Post
            if let author = post.user?.email {
                NavigationLink(destination: UserProfileView(userId: post.creatorId!)) {
                    Text("Posted by: \(author)")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                }
            }
            
            // Timestamp for Post
            Text(post.getTimeStamp())
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
            
            HStack {
                // Button for sharing post content
                Button(action: { }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.footnote)
                }.onTapGesture {
                    sharePost(post: post)
                }
                .padding(8)
                
                Spacer()
                
                // Save Button for downloading image
                Button(action: { saveImage() }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(.footnote)
                }
                .padding(8)
                
                // Hides edit/delete buttons if current user didn't make the post
                Menu {
                    if post.creatorId == Auth.auth().currentUser?.uid {
                        // Edit Post Button
                        Button(action: { editText = post.text; showEditDialog = true }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        // Delete Post Button
                        Button(action: { deletePost(postId: post.id!) }) {
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
                        .font(.title2) // Use a consistent font size
                        .foregroundColor(.primary) // Ensure the color matches your theme
                        .padding()
                }
                .frame(width: 40, height: 40) // Adjust the frame size as needed
                
            } // end of HStack
            .sheet(isPresented: $showEditDialog) {
                EditPostView(postId: post.id!, originalText: post.text)
                    .presentationDetents([.medium])
            }
            
            // Adds a horizontal line between posts
            Divider()
                .foregroundColor(.white)
            
        } // end of VStack
    } //end of view
    
    
    // Shares Post Image (Firebase url) and Text
    func sharePost(post: Post) {
        var items: [Any] = []
        
        if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
            items.append(url)
        }
        
        items.append(post.text)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        window.rootViewController?.present(av, animated: true, completion: nil)
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
                return
            }
            
            guard let uiImage = UIImage(data: data) else {
                print("Failed to convert data to image")
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
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
    
} // end of postview

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
} // end of edit post view
