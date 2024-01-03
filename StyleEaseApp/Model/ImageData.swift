//
//  ImageData.swift
//  StyleEaseApp
//
//  Created by Sam 77 on 2023-12-29.
//

import Foundation


// Models for handling fetched data

struct Category: Codable, Identifiable {
    let id: String
    let name: String
}

struct Product: Identifiable {
    let id: Int
    let name: String
    let imageName: String
    let description: String
    let size: Size // Assuming 'Size' is another custom struct for product dimensions
    let colors: [ColorOption] // Available color options
    let price: Int
    let code: String
       let fit: String
       let length: String
    let style: String
    let pattern: String
    let material: String
       let graphicalAppereance: String
       let lining: String
       let liningPercentage: Double
       let shell: String
       let shellPercentage: Double
    // Add other properties as needed for your products

    // Initialization of the Product
    init(id: Int, name: String, imageName: String, description: String, size: Size, colors: [ColorOption], price: Int, code: String, fit:String, length: String, style: String, pattern: String,material: String, graphicalAppereance: String, lining: String, liningPercentage: Double, shell: String, shellPercentage: Double) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.description = description
        self.size = size
        self.colors = colors
        self.price = price
        self.code = code
        self.fit = fit
        self.length = length
        self.style = style
        self.pattern = pattern
        self.material = material
               self.graphicalAppereance = graphicalAppereance
               self.lining = lining
               self.liningPercentage = liningPercentage
               self.shell = shell
               self.shellPercentage = shellPercentage
    }
}

struct Size {
    let height: Double
    let width: Double
    let diameter: Double
    let availableSizes: [String] // Assuming availableSizes is an array of strings
    let availableSizes: [Optional<Any>]
    // Add other size-related properties as needed
}


extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


struct ColorOption {
    let name: String
    let hexCode: String // Assuming you're using hex codes for colors
    // Add other color-related properties as needed
}


struct CategoryResponse: Codable {
    let categories: [Category]
}

//struct ProductResponse: Codable {
//    let products: [Product]
//}








struct ImageData: Identifiable, Decodable {
    var id: String = UUID().uuidString
    var imageURL: String
    var title: String
    var location: String
    var rating: String
    var filter: String
    var isFavourite: Bool
    var description: String
    var latitude: Double
    var longitude: Double
    var price: Int
}
struct UserProfileData: Identifiable, Decodable {
    var id: String? = UUID().uuidString
    var age: String?
    var bio: String?
    var email: String?
    var favorites: [String]?
    var address: String?
    var location: String?
    var firstName: String?
    var lastName: String?
    var order: String?
    var profileImageURL: String?
    var balance: Int?
}

struct FavoritesList: Identifiable, Decodable {
    var id: String = UUID().uuidString
    var imageURL: String
    var title: String
    var location: String
    var rating: String
    var filter: String
    var isFavourite: Bool
    var description: String
}
