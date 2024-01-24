//
//  ProfileScreen.swift
//  StyleEaseApp
//
//  Created by Macbook on 13/01/2024.
//

import SwiftUI

import SwiftUI
import SDWebImageSwiftUI

struct ProfileScreen: View {
    
    @State var name: String = ""
    @State var email: String = ""
    @State var phone: String = ""
    
    @State var isEditing = false
    @State var showAlert = false
    @State var message = ""
    
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var imageURL: URL?
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Personal Information")) {
                        TextField("Name", text: $name)
                            .disabled(!isEditing)
                        TextField("Email", text: $email)
                            .disabled(true)
                        TextField("Phone", text: $phone)
                            .disabled(!isEditing)
                            .keyboardType(.numberPad)
                    }
                    
                    if isEditing {
                        Section {
                            Button(action: {
                                self.setUserInfo()
                            }, label: {
                                Text("Save")
                                    .frame(maxWidth: .infinity)
                            })
                        }
                    }
                    
                    Section {
                        Button(action: {
                            viewModel.signOut()
                        }, label: {
                            Text("Logout")
                                .frame(maxWidth: .infinity)
                        })
                    }
                    
                    if StorageManager.shared.email == "developer@easeapp.com" {
                    Section(header: Text("Developer Mode Enabled")) {
                            NavigationLink {
                                AddProductScreen()
                            } label: {
                                Text("Add Products")
                                    .bold().monospaced()
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                        }

                    }
                    
                }
            }
            .navigationBarTitle("Hello, \(StorageManager.shared.name ?? "")")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isEditing.toggle()
                        
                        if isEditing == false {
                            phone = StorageManager.shared.phone ?? ""
                            name = StorageManager.shared.name ?? ""
                        }
                        
                    }) {
                        Text(isEditing ? "Cancel" : "Edit")
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Alert"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            getUserInfo()
        }
    }
    private func getUserInfo() {
        FirebaseQueryManager.shared.getUserInfo { isSuccess in
            if isSuccess {
                email = StorageManager.shared.email ?? ""
                name = StorageManager.shared.name ?? ""
                phone = StorageManager.shared.phone ?? ""
            }
        }
    }
    
    private func setUserInfo() {
        if name.isEmpty {
            message = "Name cannot be empty"
            showAlert = true
            return
        }
        
        if phone.isEmpty {
            message = "Phone number cannot be empty"
            showAlert = true
            return
        }
        
        FirebaseQueryManager.shared.updateUserInfo(name: name, phone: phone) { isSuccess, _message in
            showAlert = true
            self.message = _message
            isEditing = false
            StorageManager.shared.name = name
            StorageManager.shared.phone = phone
        }
    }
}
