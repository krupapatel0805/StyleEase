//
//  File.swift
//  StyleEaseApp
//

import SwiftUI

struct NotificationsScreen: View {
        
    @State private var notifications = [NotificationDataModel]()

    var body: some View {
        NavigationView {
            if notifications.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "bell.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red.opacity(0.5))
                    Text("No notifications have been found.")
                        .font(.headline)
                        .foregroundColor(.red.opacity(0.5))
                    Spacer()
                }
            } else {
                List(notifications) { not in
                    VStack(alignment: .leading) {
                        Text(not.notification)
                            .font(.headline)
                        Text("Order Number: \(not.orderSKU)")
                            .foregroundColor(.secondary)
                        Text(not.date)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Notifications")
            }
        }
       
        .onAppear {
            FirebaseQueryManager.shared.getNotifications() { result in
                switch result {
                case .success(let notifications):
                    self.notifications = notifications
                    print("Notifications: \(notifications)")
                case .failure(let error):
                    print("Error retrieving notifications: \(error)")
                }
            }
        }
    }
}
