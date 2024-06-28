//
//  ForgotPassword.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/28/24.
//

import SwiftUI
import Firebase

struct ForgotPasswordView: View {
    @State private var emailAddress: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Image("AppStaticImage")
                .resizable()
                   .scaledToFit()
                   .frame(width: 150, height: 150)
            
            Text("Reset Password")
                .font(.system(size: 40, weight: .medium, design: .default))
                .foregroundColor(.red)
            
            Text("Please enter the email address used when signing up to receive a link to reset your password.")
                .font(.system(size: 15, weight: .medium, design: .default))
                .padding()
            
            TextField("Email", text: $emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5)
                .padding(.horizontal)

            Button(action: resetPassword) {
                Text("Reset Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(5)
                    .padding(.horizontal)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Password Reset"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    if alertMessage == "Password reset email sent." {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                })
            }
        }
        .padding()
    }

    private func resetPassword() {
        let trimmedEmail = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        FirebaseAuth.Auth.auth().sendPasswordReset(withEmail: trimmedEmail) { error in
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "Password reset email sent."
            }
            showingAlert = true
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
