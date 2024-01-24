//
//  OrderDataModel.swift
//  StyleEaseApp
//
//  Created by Macbook on 13/01/2024.
//

import Foundation

struct OrderDataModel: Identifiable, Codable {
    var id = UUID() // orderId
    var productIds: [String]
    var price: String
    var userId: String
    var orderDate: String
    var orderSKU: String
    
    var asDictionary: [String: Any] {
        [
            "id": id.uuidString,
            "productIds": productIds,
            "price": price,
            "userId": userId,
            "orderDate": orderDate,
            "orderSKU": orderSKU
        ]
    }
}

