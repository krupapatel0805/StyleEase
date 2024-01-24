//
//  AuthenticationManager.swift
//  StyleEaseApp
//

import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let name: String?
    let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.name = user.displayName
        self.photoUrl = user.photoURL?.absoluteString
    }
}

class AuthenticationManager: ObservableObject {

    static let shared = AuthenticationManager()
    
    private init() {}
    
    //Signup
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authData = try await Auth.auth().createUser(withEmail: email, password: password)
        StorageManager.shared.userId = authData.user.uid
        return AuthDataResultModel(user: authData.user)
    }
    
    //Login
    func loginUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authData = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authData.user)
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func registerUserInDatabase(user: AuthDataResultModel, name: String, phone: String) async throws -> (Bool, String) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")

        do {
            let document = try await usersCollection.document(user.uid).getDocument()

            if document.exists {
                return (false, "User with the following email already exists")
            } else {
                let userData: [String: Any] = [
                    "email": user.email ?? "",
                    "id": user.uid,
                    "name": name,
                    "phone": phone
                ]

                try await usersCollection.document(user.uid).setData(userData)

                return (true, "User registered successfully")
            }
        } catch {
            return (false, "Something went wrong while registering the user")
        }
    }

}
