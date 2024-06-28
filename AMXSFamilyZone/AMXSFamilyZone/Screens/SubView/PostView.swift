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
        VStack(alignment: .leading, spacing: 8) {
            if let imageUrl = post.imageUrl, !imageUrl.isEmpty {
                WebImage(url: URL(string: imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width * 0.75)
                    .cornerRadius(8)
                    .padding(.bottom, 8)
            }
            
            Text(post.text)
                .font(.callout)
                .foregroundColor(.primary)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.top, post.imageUrl == nil ? 8 : 0)  // Additional top padding if there's no image
            
            if let author = post.user?.email {
                Text(author)
                    .font(.footnote)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
            }
            
            Text(post.getTimeStamp())
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.bottom, 8) // Added bottom padding for text-only posts
            
            HStack {
                Button(action: {
                    sharePost(post: post)
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .padding(8)
                .contentShape(Rectangle())
                
                Spacer()
                
                if post.creatorID == Auth.auth().currentUser?.uid {
                    Menu {
                        Button(action: {
                            editText = post.text
                            showEditDialog = true
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            deletePost(postId: post.id!)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis")
                    }
                    .padding(8)
                    .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.systemBackground)))
        .shadow(color: Color.primary.opacity(0.2), radius: 2, x: 0, y: 2)
        .padding([.horizontal, .top], 8)
        .sheet(isPresented: $showEditDialog) {
            EditPostView(postId: post.id!, originalText: post.text)
        }
    }
    
    func sharePost(post: Post) {
        let items: [Any] = post.imageUrl == nil ? [post.text] : [URL(string: post.imageUrl!)!]
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        window.rootViewController?.present(av, animated: true, completion: nil)
    }
    
    func deletePost(postId: String) {
        let firestore = Firestore.firestore()
        let documentReference = firestore.collection("Post").document(postId)
        
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
               existingPost.creatorID == Auth.auth().currentUser?.uid {
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
        }
        .onAppear {
            newText = originalText
        }
    }
    
    func updatePost(postId: String, newText: String) {
        let firestore = Firestore.firestore()
        let documentReference = firestore.collection("Post").document(postId)
        
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
               existingPost.creatorID == Auth.auth().currentUser?.uid {
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
}
