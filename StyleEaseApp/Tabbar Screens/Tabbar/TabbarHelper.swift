//
//  TabbarHelper.swift
//  StyleEaseApp
//

import SwiftUI

struct TabbarHelper: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house.circle.fill")
                    Text("Home")
                }
                .tag(0)
            
            CartScreen()
                .tabItem {
                    Image(systemName: "cart.circle.fill")
                    Text("My Cart")
                }
                .tag(1)
            
            NotificationsScreen()
                .tabItem {
                    Image(systemName: "bell.circle.fill")
                    Text("Notifications")
                }
                .tag(2)
            
            MyOrdersScreen()
                .tabItem {
                    Image(systemName: "bag.circle.fill")
                    Text("My Orders")
                }
                .tag(3)
            
            ProfileScreen(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
                .tag(4)
            
//            if StorageManager.shared.email == "Developer@easeapp.com" {
//                AddProductScreen()
//                    .tabItem {
//                        Image(systemName: "circle.fill")
//                        Text("Add Product")
//                    }
//                    .tag(5)
//            }
            
        }
        .accentColor(.red)
        .toolbar(.hidden, for: .navigationBar)
    }
}
