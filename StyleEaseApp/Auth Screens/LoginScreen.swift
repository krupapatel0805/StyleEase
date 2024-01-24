//
//  LoginScreen.swift
//  StyleEaseApp
//


import SwiftUI

struct LoginScreen: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        if !viewModel.isAuthenticated {
            VStack() {
                HStack {
                    Text("Login")
                        .font(.title)
                        .bold().monospaced()
                        .foregroundStyle(.black)
                }
                
                TextField("Email", text: $viewModel.email)
                    .padding()
                    .frame(height: 44)
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black, lineWidth: 0.5)
                    )

                Spacer().frame(height: 16)
                
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .frame(height: 44)
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black, lineWidth: 0.5)
                    )
                
                Spacer().frame(height: 30)
                
                Button(action: {
                    viewModel.login()
                }, label: {
                    Text("Login")
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
                
                HStack {
                    Spacer()
                    
                    Text("Dont have an account?")
                        .font(.footnote)
                    
                    NavigationLink {
                        SignupScreen(viewModel: viewModel)
                    } label: {
                        Text("Register Now")
                            .bold().monospaced()
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
             
            }
            .padding(.horizontal, 20)
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                TabbarHelper(viewModel: viewModel)
            }
            .alert(isPresented: $viewModel.isInValidForm) {
                Alert(
                    title: Text("Warning"),
                    message: Text("Please enter valid email and password"),
                    dismissButton: .default(Text("OK"))
                )
            }
        } else {
            TabbarHelper(viewModel: viewModel)
        }
        
    }
}

#Preview {
    LoginScreen()
}
