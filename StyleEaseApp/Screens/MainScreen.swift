//
//  MainScreen.swift
//  StyleEase
//
//  Created by Sam 77 on 2023-12-21.
//

import Foundation
import SwiftUI

struct MainScreen: View {
    @State var age = ""
    @Binding var isLoggedIn : Bool
    @StateObject private var authViewModel = AuthViewModel()
    var body: some View {
        NavigationView {
            VStack() {
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 350, height: 250)
                    .background(
                        Image("Logo")
                    )
                    .padding(.bottom,50)

                Text("create your own style...")
                  .font(
                    Font.custom("Roboto", size: 24)
                      .weight(.medium)
                  )
                  .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                    .padding(10)
                
                NavigationLink(destination: SignInScreen(isLoggedIn: $isLoggedIn,authViewModel: authViewModel)) {
                    Text("Sign in")
                        .font(Font.custom("Roboto", size: 14).weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                        .frame(width: 200, height: 35)
                        .background(Color(red: 0.85, green: 0.78, blue: 0.7))
                        .cornerRadius(5)
                        .shadow(color: Color(red: 0.27, green: 0.57, blue: 0.85).opacity(0.25), radius: 3.5, x: 0, y: 4)
                }
                .navigationBarBackButtonHidden(true)
                
                NavigationLink(destination: SignUpScreen( isLoggedIn: _isLoggedIn, authViewModel: authViewModel)) {
                    Text("Sign up")
                        .font(Font.custom("Roboto", size: 14).weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                        .frame(width: 200, height: 35)
                        .background(Color(red: 0.82, green: 0.69, blue: 0.52))
                        .cornerRadius(5)
                        .shadow(color: Color(red: 0.27, green: 0.57, blue: 0.85).opacity(0.25), radius: 3.5, x: 0, y: 4)
                }
                .navigationBarBackButtonHidden(true)
                
            }
//            .frame(width: 414, height: 736)
//            .background(.white)
//            .shadow(
//                color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 4, y: 4
//            )
        }
    }
}
