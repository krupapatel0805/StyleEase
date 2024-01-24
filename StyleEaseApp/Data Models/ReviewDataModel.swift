//
//  ReviewDataModel.swift
//  StyleEaseApp
//
//  Created by Macbook on 13/01/2024.
//

import Foundation

struct ReviewDataModel: Identifiable, Codable {
    var id = UUID()
    var productId: String
    var review: String
    var date: String
    var orderSKU: String
    var rating: Double
    var userId: String = ""
    
    var asDictionary: [String: Any] {
        [
            "id": id.uuidString,
            "productId": productId,
            "review": review,
            "date": date,
            "orderSKU": orderSKU,
            "rating":rating,
            "userId":userId
        ]
    }
}
