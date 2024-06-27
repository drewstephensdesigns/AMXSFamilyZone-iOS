//
//  AuthManager.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/6/24.
//

import SwiftUI
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.isLoggedIn = user != nil
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
