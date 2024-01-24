//
//  AuthenticationViewModel.swift
//  StyleEaseApp
//

import Foundation
import FirebaseAuth

enum CustomError: Error {
    case authenticationFailed
    case error(msg: String)
    case unknown
}


@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    @Published var name = ""
    @Published var email = "Developer@easeapp.com"
    @Published var password = "12121212"
    @Published var phone = ""
    @Published var confirmPassword = ""
    
    @Published var isProcessing = false
    @Published var isAuthenticated: Bool = false
    @Published var isInValidForm: Bool = false
    @Published var authMessage: String = ""
    
    func login() {
        
        if !email.isValidateEmail() || !password.isValidPassword() {
            isInValidForm = true
            return
        }
        isProcessing = true
        Task {
            do {
                let user = try await AuthenticationManager.shared.loginUser(email: email, password: password)
                StorageManager.shared.email = email
                StorageManager.shared.userId = user.uid
                isAuthenticated = true
                isProcessing = false
            } catch {
                print("Error: \(error)")
                isInValidForm = true
                isProcessing = false
            }
        }
    }
    
    func registerUser() {
        
//        if !email.isValidateEmail()
//            || !password.isValidPassword()
//            || name.isEmpty
//            || (password != confirmPassword)
//            || phone.isEmpty {
//            isInValidForm = true
//            return
//        }
//        
        if name.isEmpty {
            authMessage = "Name cannot be empty"
            isInValidForm = true
            return
        }
        
        if !email.isValidateEmail() {
            authMessage = "Invalid email address"
            isInValidForm = true
            return
        }
        
        if phone.isEmpty {
            authMessage = "Phone number cannot be empty"
            isInValidForm = true
            return
        }

        if !password.isValidPassword() {
            authMessage = "Invalid password. Password must be greater than 6 characters"
            isInValidForm = true
            return
        }

        if password != confirmPassword {
            authMessage = "Passwords do not match"
            isInValidForm = true
            return
        }
        
        isProcessing = true
        
        Task {
            do {
                let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
                let response = try await AuthenticationManager.shared.registerUserInDatabase(user: returnedUserData, name: name, phone: phone)
                isProcessing = false
                isAuthenticated = true
                authMessage = response.1
            } catch let err {
                authMessage = err.localizedDescription
                isProcessing = false
                isInValidForm = true
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
