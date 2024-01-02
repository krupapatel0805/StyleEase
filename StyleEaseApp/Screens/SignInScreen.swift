//
//  SignInScreen.swift
//  StyleEase
//
//  Created by Sam 77 on 2023-12-21.
//

import Foundation
import SwiftUI

struct SignInScreen: View {
    @Binding var isLoggedIn: Bool
       @ObservedObject var authViewModel: AuthViewModel
       @State private var email = ""
       @State private var password = ""
       @State private var isSigningIn = false
       @State private var isShowingPopup1 = false
       @State private var isSignUpActive = false
    
    var body: some View {
        if authViewModel.isAuthenticated {
            MainTabbedView(authViewModel: authViewModel)
        } else {
            NavigationView {
                VStack {
                    VStack() {
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                          .font(
                            Font.custom("Roboto", size: 14)
                              .weight(.bold)
                          )
                          .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                        
                        TextField("Input your email", text: $email)
                            .font(
                            Font.custom("Roboto", size: 14)
                            .weight(.light)
                            )
                            .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                            .padding()
//                            .foregroundColor(.clear)
                            .frame(width: 350, height: 35)
                            .background(.white.opacity(0.56))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                  .inset(by: 0.5)
                                  .stroke(Color(red: 0.57, green: 0.44, blue: 0.2), lineWidth: 1)
                              )
                            .textContentType(.emailAddress)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password")
                            .font(
                              Font.custom("Roboto", size: 14)
                                .weight(.bold)
                            )
                            .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                        
                        SecureField("******", text: $password)
                            .font(
                            Font.custom("Roboto", size: 14)
                            .weight(.light)
                            )
                            .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                            .padding()
//                            .foregroundColor(.clear)
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
                        signIn()
                    }) {
                        Text("Sign In")
                            .font(Font.custom("Roboto", size: 14).weight(.bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                            .frame(width: 200, height: 35)
                            .background(Color(red: 0.85, green: 0.78, blue: 0.7))
                            .cornerRadius(5)
                            .shadow(color: Color(red: 0.27, green: 0.57, blue: 0.85).opacity(0.25), radius: 3.5, x: 0, y: 4)
                    }
                    .overlay(
                        isSigningIn ? ProgressView() : nil
                    )

                    Spacer()
                        .frame(height: 20)

                    NavigationLink(
                                           destination: SignUpScreen(isLoggedIn: $isLoggedIn, authViewModel: authViewModel),
                                           isActive: $isSignUpActive,
                                           label: {
                                               Text("Don’t have an account? Sign up")
                                                   .font(Font.custom("Roboto", size: 12).weight(.light))
                                                   .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                                           }
                                       )
                                   }
                .toolbar {
                                   ToolbarItem(placement: .navigationBarLeading) {
                                       EmptyView()
                                   }
                           }                .padding(20)
                    .navigationBarHidden(true)
                               .onAppear {
                                   isSigningIn = false
                               }
                .alert(isPresented: $isShowingPopup1) {
                                   Alert(
                                       title: Text("Invalid Credential"),
                                       message: Text("Please try again"),
                                       dismissButton: .default(Text("OK"))
                                   )
                               }
            }
        }
    }
    
    private func signIn() {
           isSigningIn = true
           authViewModel.email = email
           authViewModel.password = password
           authViewModel.signIn { isSuccess in
               if isSuccess {
                   isLoggedIn = true // Update the binding to navigate to HomeScreen
               } else {
                   isShowingPopup1 = true
               }
               isSigningIn = false
           }
       }
   }
