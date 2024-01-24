//
//  StorageManager.swift
//  StyleEaseApp
//

import Foundation

class StorageManager: NSObject, ObservableObject {
    
    static let shared = StorageManager()
    
    var email: String? {
        didSet {
            UserDefaults.standard.set(self.email, forKey: StorageKeys.email)
        }
    }
    
    var name: String? {
        didSet {
            UserDefaults.standard.set(self.name, forKey: StorageKeys.name)
        }
    }
    
    var phone: String? {
        didSet {
            UserDefaults.standard.set(self.phone, forKey: StorageKeys.phone)
        }
    }
    
    
    var userId: String? {
        didSet {
            UserDefaults.standard.set(self.userId, forKey: StorageKeys.userId)
        }
    }
}

struct StorageKeys {
    static let email = "email"
    static let name = "name"
    static let phone = "phone"
    static let userId = "userId"
}
