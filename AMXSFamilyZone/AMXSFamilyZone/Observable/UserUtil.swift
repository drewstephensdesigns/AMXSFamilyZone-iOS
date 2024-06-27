//
//  UserUtil.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/9/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserUtil: ObservableObject {
    @Published var user: User? = nil

    static let shared = UserUtil()

    private init() {
        // Fetch the current user when this singleton is initialized
        getCurrentUser()
    }

    func getCurrentUser() {
        if let currentUser = Auth.auth().currentUser {
            Firestore.firestore().collection("Users").document(currentUser.uid).getDocument { document, error in
                if let document = document, document.exists {
                    do {
                        if let user = try document.data(as: User?.self) {
                            DispatchQueue.main.async {
                                self.user = user
                            }
                        }
                    } catch {
                        print("Error decoding user: \(error)")
                    }
                } else {
                    print("User does not exist")
                }
            }
        }
    }
}
