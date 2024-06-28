//
//  RegisterView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/28/24.
//

import SwiftUI
import Firebase

struct RegisterView: View {
    
    @State private var userFullName: String = ""
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var userPassword: String = ""
    @State private var errorMessage: String? = nil
    @State private var showMainActivity: Bool = false
    @State private var showLoginActivity: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Image("AppStaticImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Text("Sign Up")
                    .font(.system(size: 40, weight: .medium, design: .default))
                    .foregroundColor(.red)
                    .padding()
                
                Text("Welcome to the 317th AMXS Family Zone! View upcoming information and connect with 317 AMXS family, both active duty and spouses.")
                    .font(.system(size: 15, weight: .light, design: .default))
                    .multilineTextAlignment(.center)
                    .padding()
                
                TextField("Full Name", text: $userFullName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .autocapitalization(.none)

                TextField("Username", text: $userName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .autocapitalization(.none)

                TextField("Email", text: $userEmail)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .autocapitalization(.none)

                SecureField("Password", text: $userPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    signIn()
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(5.0)
                }
                .padding(.top, 20)

                Button(action: {
                    showLoginActivity = true
                }) {
                    Text("Already have an account? Log In")
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
                .navigationDestination(isPresented: $showLoginActivity) {
                    LoginView()
                }
            }
            .padding()
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showMainActivity) {
                ContentView()
            }
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                let username = user.email?.split(separator: "@").first ?? ""
                errorMessage = "Welcome back, \(username)!"
                showMainActivity = true
            }
        }
    }

    private func signIn() {
        guard !userFullName.isEmpty, !userName.isEmpty, !userEmail.isEmpty, !userPassword.isEmpty else {
            errorMessage = "All fields are required"
            return
        }

        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
            if let error = error {
                errorMessage = "Sign up failed: \(error.localizedDescription)"
            } else {
                if let uid = authResult?.user.uid {
                    let user = ["uid": uid, "username": userName, "email": userEmail]
                    Firestore.firestore().collection("Users").document(uid).setData(user) { error in
                        if let error = error {
                            errorMessage = "Sign up failed: \(error.localizedDescription)"
                        } else {
                            errorMessage = "Sign up successful"
                            showMainActivity = true
                        }
                    }
                }
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
