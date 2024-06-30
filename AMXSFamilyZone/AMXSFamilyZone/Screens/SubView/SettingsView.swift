//
//  SettingsView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/28/24.
//

import SwiftUI
import Firebase
import MessageUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("isNotificationsEnabled") private var notificationsEnabled = true
    
    @State private var showingDeleteAlert = false
    @State private var showingSignOutAlert = false
    
    //@State
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isShowingMailView = false
    @State private var isShowingMailErrorAlert = false
    @State private var mailComposeResult: Result<MFMailComposeResult, Error>? = nil

    var body: some View {
        List {
            Section(header: Text("Account")) {
                Button(action: {
                    showingSignOutAlert = true
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
                .alert(isPresented: $showingSignOutAlert) {
                    Alert(
                        title: Text("Sign Out"),
                        message: Text("Are you sure you want to sign out?"),
                        primaryButton: .destructive(Text("Sign Out")) {
                            signOut()
                        },
                        secondaryButton: .cancel()
                    )
                }
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Text("Delete Account")
                        .foregroundColor(.red)
                        .bold()
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("This action cannot be undone. Are you sure you want to delete your account?"),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteAccount()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            Section(header: Text("Legal")) {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Privacy Policy")
                }
                Link("Source Code", destination: URL(string: Consts.SOURCE_CODE)!)
            }
            Section(header: Text("Preferences")) {
                Toggle(isOn: $isDarkMode) {
                    Text("Dark Mode")
                }
                .onChange(of: isDarkMode) {
                    if isDarkMode == true {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            for window in windowScene.windows {
                                window.overrideUserInterfaceStyle = .dark
                            }
                        }
                      } else {
                          if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                              for window in windowScene.windows {
                                  window.overrideUserInterfaceStyle = .light
                              }
                          }
                      }
                }

                Toggle(isOn: $notificationsEnabled) {
                    Text("Enable Notifications")
                }
                .onChange(of: notificationsEnabled) {
                    if notificationsEnabled == true{
                        enableNotifications()
                    } else {
                        disableNotifications()

                    }
                }
            }
            Section(header: Text("Support")) {
                Button(action: {
                    if MailView.canSendMail {
                        isShowingMailView = true
                    } else {
                        isShowingMailErrorAlert = true
                    }
                }) {
                    Text("Feedback")
                }
                .sheet(isPresented: $isShowingMailView) {
                    MailView(result: self.$mailComposeResult)
                }
                .alert(isPresented: $isShowingMailErrorAlert) {
                    Alert(
                        title: Text("Cannot Send Mail"),
                        message: Text("Your device is not configured to send email. Please set up an email account and try again."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        .navigationTitle("Settings")

    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func deleteAccount() {
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                print("Error deleting account: \(error.localizedDescription)")
            } else {
                print("Account deleted successfully")
            }
        }
    }

    func enableNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications enabled")
            } else {
                print("Notifications not enabled: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    func disableNotifications() {
        print("Notifications disabled")
        // Implement any additional logic to handle disabling notifications
    }
}

// Other structs remain unchanged

struct PrivacyPolicyView: View {
    var body: some View {
        WebView(url: URL(string: "https://drewstephensdesigns.github.io/privacy-policy/amxs-family-zone")!)
            .navigationTitle("Privacy Policy")
    }
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentation: Binding<PresentationMode>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            if let error = error {
                self.result = .failure(error)
            } else {
                self.result = .success(result)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation, result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["drewstephensdesigns@gmail.com"])
        vc.setSubject("Feedback")
        vc.setMessageBody("Your feedback here", isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {
    }

    static var canSendMail: Bool {
        return MFMailComposeViewController.canSendMail()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
