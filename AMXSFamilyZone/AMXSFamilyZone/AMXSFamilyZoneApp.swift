//
//  AMXSFamilyZoneApp.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/27/24.
//

import SwiftUI
import Firebase

@main
struct AMXSFamilyZoneApp: App {
    @StateObject private var authManager = AuthManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                ContentView() // The view for logged-in users
                    .onAppear {
                        UNUserNotificationCenter.current().delegate = appDelegate
                        if let displayName = Auth.auth().currentUser?.email {
                            print("Logged In: \(displayName)")
                        } else {
                            print("Logged In: User has no display name")
                        }
                    }
            } else {
                RegisterView() // The view for users to register/login
            }
        }
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            UNUserNotificationCenter.current().delegate = self
            return true
        }

        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .sound, .badge])
        }
    }
}
