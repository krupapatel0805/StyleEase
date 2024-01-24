//
//  SignupScreen.swift
//  StyleEaseApp
//


import Foundation
import SwiftUI

struct SignupScreen: View {
    
    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        ZStack {
            VStack() {
                Text("Signup")
                    .font(.title)
                    .bold().monospaced()
                
                SignupFieldsView(viewModel: viewModel)
                
                Spacer().frame(height: 30)
                
                Button(action: {
                    viewModel.registerUser()
                }, label: {
                    Text("Signup")
                        .frame(height: 20)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.vertical)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(6)
                        .bold().monospaced()
                })
                .overlay(
                    viewModel.isProcessing  ? ProgressView() : nil
                )
                
                
            }
            .padding(.horizontal, 20)
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                TabbarHelper(viewModel: viewModel)
            }
            .alert(isPresented: $viewModel.isInValidForm) {
                Alert(
                    title: Text("Alert"),
                    message: Text(viewModel.authMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                viewModel.email = ""
                viewModel.password = ""
                viewModel.name = ""
                viewModel.confirmPassword = ""
                viewModel.phone = ""
            }
        }
    }
}

struct SignupFieldsView: View {
    
    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            TextFieldView(title: "Name", text: $viewModel.name)
            TextFieldView(title: "Email", text: $viewModel.email)
            TextField("Phone", text: $viewModel.phone)
                .padding()
                .frame(height: 44)
                .background(.white)
                .keyboardType(.phonePad)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black, lineWidth: 0.5)
                )
            SecureTextFieldView(title: "Password", text: $viewModel.password)
            SecureTextFieldView(title: "Confirm Password", text: $viewModel.confirmPassword)
        }
    }
}

#Preview {
    SignupScreen(viewModel: AuthenticationViewModel())
}


struct TextFieldView: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        TextField(title, text: $text)
            .padding()
            .frame(height: 44)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.black, lineWidth: 0.5)
            )
    }
}

struct SecureTextFieldView: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        SecureField(title, text: $text)
            .padding()
            .frame(height: 44)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.black, lineWidth: 0.5)
            )
    }
}
