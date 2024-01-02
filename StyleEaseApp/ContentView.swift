//
//  ContentView.swift
//  StyleEase
//
//  Created by Sam 77 on 2023-12-21.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplashScreen = true
    @State private var isLoggedIn = false // Check the user's authentication status here

    var body: some View {
        NavigationView {
            ZStack {
                if showSplashScreen {
                    SplashScreen(isShowing: $showSplashScreen)
                } else {
                    if isLoggedIn {
                        HomeScreen()
                    } else {
                        MainScreen(isLoggedIn: $isLoggedIn)
                    }
                }
            }
            .navigationBarHidden(true) // Hide the navigation bar for all views
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                withAnimation {
                    self.showSplashScreen = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
