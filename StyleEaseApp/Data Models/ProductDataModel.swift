//
//  ProductDataModel.swift
//  StyleEaseApp
//
//  Created by Macbook on 12/01/2024.
//

import Foundation

struct ProductDataModel: Identifiable, Codable {
    var id = UUID().uuidString
    var category: String
    var description: String
    var imageUrl: String
    var sold: Int
    var subCategory: String
    var price: String
    var name: String
    var size: String = ""
    var quantity: String = ""
    
    var asDictionary: [String: Any] {
        [
            "id": id,
            "category": category,
            "description": description,
            "imageUrl": imageUrl,
            "sold": sold,
            "subCategory": subCategory,
            "price": price,
            "name": name,
            "size": size,
            "quantity": quantity
        ]
    }
}

