//
//  StyleEaseAppApp.swift
//  StyleEaseApp
//


import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import IQKeyboardManagerSwift
@main
struct StyleEaseAppApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SplashScreen()
            }
            .tint(.red)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        return true
    }
}
