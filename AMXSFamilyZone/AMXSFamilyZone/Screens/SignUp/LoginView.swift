//
//  LoginView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/28/24.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State private var signInEmail: String = ""
    @State private var signInPassword: String = ""
    @State private var errorMessage: String? = nil
    @State private var navigatedToContent = false

    var body: some View {
        NavigationStack {
            VStack {
                Image("AppStaticImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)

                Text("Sign In")
                    .font(.system(size: 40, weight: .medium, design: .default))
                    .foregroundColor(.red)

                Text("Welcome back! Sign in to continue")
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .padding()

                TextField("Email", text: $signInEmail)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .autocapitalization(.none)

                SecureField("Password", text: $signInPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    signInUser()
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(5.0)
                }
                .padding(.top, 20)

                NavigationLink("Forgot Password?", destination: ForgotPasswordView())
                    .foregroundColor(.blue)
                    .padding(.top, 10)

                // Navigation to ContentView
                NavigationLink("", destination: ContentView(), isActive: $navigatedToContent)
            }
            .padding()
        }
    }

    private func signInUser() {
        guard !signInEmail.isEmpty, !signInPassword.isEmpty else {
            errorMessage = "Email and Password are required"
            return
        }

        Auth.auth().signIn(withEmail: signInEmail, password: signInPassword) { authResult, error in
            if let error = error {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            } else {
                if let currentUserEmail = Auth.auth().currentUser?.email {
                    errorMessage = "Welcome Back \(currentUserEmail)"
                    // Trigger the navigation to ContentView
                    navigatedToContent = true
                }
            }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
