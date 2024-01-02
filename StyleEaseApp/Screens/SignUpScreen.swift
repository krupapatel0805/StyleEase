//
//  SignUpScreen.swift
//  StyleEase
//
//  Created by Sam 77 on 2023-12-21.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

struct SignUpScreen: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var isProcessing = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                VStack() {
                    Spacer()
                    Text("StyleEase")
                      .font(Font.custom("Acme", size: 50))
                      .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                    .padding(.bottom, 20)
                }

                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 166, height: 140)
                    .background(
                        Image("Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 166, height: 140)
                            .clipped()
                            .opacity(0.8)
                            .cornerRadius(5)
                    )

                CustomTextField(title: "First Name", text: $firstname, contentType: .name)
                CustomTextField(title: "Last Name", text: $lastname, contentType: .name)
                CustomTextField(title: "Email", text: $email, contentType: .emailAddress)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Password")
                        .font(
                            Font.custom("Roboto", size: 14)
                                .weight(.bold)
                        )
                        .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))

                    SecureField("******", text: $password)
                        .font(Font.custom("Roboto", size: 14).weight(.light))
                        .padding()
                        .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                        .frame(width: 350, height: 35)
                        .background(.white.opacity(0.56))
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0.57, green: 0.44, blue: 0.2), lineWidth: 1)
                            )
                        .textContentType(.password)
                }
                Spacer()

                Button(action: {
                    signUp()
                }) {
                    Text("Sign up")
                        .font(Font.custom("Roboto", size: 14).weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                        .frame(width: 200, height: 35)
                        .background(Color(red: 0.85, green: 0.78, blue: 0.7))
                        .cornerRadius(5)
                        .shadow(color: Color(red: 0.27, green: 0.57, blue: 0.85).opacity(0.25), radius: 3.5, x: 0, y: 4)
                }

                NavigationLink(
                    destination: SignInScreen(isLoggedIn: $isLoggedIn, authViewModel: authViewModel),
                    label: {
                        Text("Already have an account? Sign in")
                            .font(
                                Font.custom("Roboto", size: 12)
                                    .weight(.light)
                            )
                            .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                    }
                )
            }
            .padding()
            .toolbar {
                           // Hide the navigation back button
                           ToolbarItem(placement: .navigationBarLeading) {
                               EmptyView()
                           }
                       }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertTitle == "Success" {
                        isLoggedIn = true // Set the user as logged in after successful sign up
                    }
                }
            )
        }
    }

    private func signUp() {
        // Validate input fields here

        isProcessing = true
        authViewModel.email = email
        authViewModel.password = password
        authViewModel.firstname = firstname
        authViewModel.lastname = lastname

        authViewModel.signUp { isSuccess in
            if isSuccess ?? false {
                showAlert(title: "Success", message: "Account Created Successfully")
            } else {
                showAlert(title: "Error", message: "Failed to create an account")
            }
            isProcessing = false
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct CustomTextField: View {
    var title: String
    @Binding var text: String
    var contentType: UITextContentType

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(
                    Font.custom("Roboto", size: 14)
                        .weight(.bold)
                )
                .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))

            TextField(title, text: $text)
                .font(
                    Font.custom("Roboto", size: 14)
                        .weight(.light)
                )
                .padding()
                .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                .frame(width: 350, height: 35)
                .background(.white.opacity(0.56))
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.57, green: 0.44, blue: 0.2), lineWidth: 1)
                    )
                .textContentType(contentType)
        }
    }
}

struct SignUpScreen_Previews: PreviewProvider {
   
    static var previews: some View {
        @State var age = ""
        SignUpScreen(isLoggedIn: .constant(false), authViewModel: AuthViewModel())
    }
    
}
extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

}
