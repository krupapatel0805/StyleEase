//
//  OrderInfoDataModel.swift
//  StyleEaseApp
//
//  Created by Macbook on 13/01/2024.
//

import Foundation

struct OrderInfoDataModel: Identifiable, Codable {
    var id = UUID()
    var name: String
    var email: String
    var phone: String
    var country: String
    var streetAddress: String
    var area: String
    var postalCode: String
    var paymentMethod: String
    var amount: String
    var products: [String]
    var orderDate: String
    var orderSKU: String
    
    var asDictionary: [String: Any] {
        [
            "id": id.uuidString,
            "name": name,
            "email": email,
            "phone": phone,
            "country": country,
            "streetAddress": streetAddress,
            "area": area,
            "postalCode": postalCode,
            "paymentMethod": paymentMethod,
            "amount": amount,
            "products": products,
            "orderDate": orderDate,
            "orderSKU": orderSKU
        ]
    }
}

struct NotificationDataModel: Identifiable, Codable {
    var id = UUID()
    var notification: String
    var orderSKU: String
    var date: String
    
    var asDictionary: [String: Any] {
        [
            "id": id.uuidString,
            "notification": notification,
            "orderSKU": orderSKU,
            "date": date
        ]
    }
}
