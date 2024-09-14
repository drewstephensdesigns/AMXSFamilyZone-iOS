//
//  PostListenerViewModel.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/22/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import UserNotifications
import Combine

class PostListenerViewModel: ObservableObject {
    private let firestore = Firestore.firestore()
    private let postsCollection: CollectionReference
    private var postListenerRegistration: ListenerRegistration?
    private let currentUser = Auth.auth().currentUser
    private var notifiedPostIDs = Set<String>() // Add this property to track notified posts

    init() {
        postsCollection = firestore.collection(Consts.POST_NODE) // Replace with your collection name
        //setupPostListener()
    }

     func setupPostListener() {
        postListenerRegistration = postsCollection.addSnapshotListener { [weak self] (snapshots, error) in
            guard let self = self, let snapshots = snapshots else {
                print("Listen failed: \(error?.localizedDescription ?? "unknown error")")
                return
            }

            for documentChange in snapshots.documentChanges {
                if documentChange.type == .added {
                    if let post = try? documentChange.document.data(as: Post.self) {
                        // Check if the post's ID is already in notifiedPostIDs
                        if let postId = post.id, !self.notifiedPostIDs.contains(postId) {
                            // Add post ID to set to prevent duplicate notifications
                            self.notifiedPostIDs.insert(postId)
                            
                            // Send notification for new post
                            self.sendNewPostNotification(post: post)
                        } else {
                            // Avoid duplicate notification by skipping already notified posts
                            print("Post with ID \(post.id ?? "unknown") already notified.")
                        }
                    } else {
                        print("Error decoding post")
                    }
                }
            }
        }
    }

    private func sendNewPostNotification(post: Post) {
        let content = UNMutableNotificationContent()
        content.title = "New Post by \(post.user?.name ?? "Unknown User")"
        content.body = post.text
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
        
    }

    deinit {
        postListenerRegistration?.remove()
    }
}
