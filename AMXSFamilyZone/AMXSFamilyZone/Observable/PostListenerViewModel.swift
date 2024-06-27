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
        postsCollection = firestore.collection("Post") // Replace with your collection name
        setupPostListener()
        requestNotificationPermissions()
    }

    private func setupPostListener() {
        postListenerRegistration = postsCollection.addSnapshotListener { [weak self] (snapshots, error) in
            guard let self = self, let snapshots = snapshots else {
                print("Listen failed: \(error?.localizedDescription ?? "unknown error")")
                return
            }

            for documentChange in snapshots.documentChanges {
                if documentChange.type == .added {
                    let post = try? documentChange.document.data(as: Post.self)
                    if let post = post, post.creatorID != self.currentUser?.uid {
                        if !self.notifiedPostIDs.contains(post.id ?? "") { // Check if the post ID is already notified
                            self.notifiedPostIDs.insert(post.id ?? "") // Add the post ID to the set
                            self.sendNewPostNotification(post: post)
                        }
                    }
                }
            }
        }
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Failed to request notification permissions: \(error.localizedDescription)")
            } else if !granted {
                print("Notification permission not granted.")
            } else {
                print("Notification permission granted.")
            }
        }
    }

    private func sendNewPostNotification(post: Post) {
        let content = UNMutableNotificationContent()
        content.title = "New Post by \(post.user?.email ?? "Unknown User")"
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
