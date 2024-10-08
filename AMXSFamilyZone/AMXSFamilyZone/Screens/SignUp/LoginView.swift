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
                    .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)

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
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.red, Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.top, 20)

                NavigationLink("Forgot Password?", destination: ForgotPasswordView())
                    .font(.custom("Cochina", size: 17))
                    .foregroundColor(.blue)
                    .padding(.top, 10)

                // Navigation to ContentView
                // This replaces the deprecated NavigationLink
                .navigationDestination(isPresented: $navigatedToContent) {
                    ContentView()
                }
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
