//
//  SearchProductsScreen.swift
//  StyleEaseApp
//
//  Created by Macbook on 13/01/2024.
//

import SwiftUI

struct SearchProductsScreen: View {
    @Binding var products: [ProductDataModel]
    @State private var searchText = ""

    var body: some View {
        List(filteredProducts, id: \.id) { product in
            NavigationLink(destination: ProductDetailScreen(product: product)) {
                ProductSearchListCell(product: product)
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Search for Products")
    }

    private var filteredProducts: [ProductDataModel] {
        if searchText.isEmpty {
            return []
        } else {
            return products.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}


struct ProductSearchListCell: View {
    var product: ProductDataModel
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(product.name).bold()
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Spacer()
                }
                HStack {
                    Text("Price: $\(product.price)")
                        .foregroundStyle(.white)
                        .font(.footnote)
                    Spacer()
                }
            }
            .padding(8)
            
        }
        .background(.red)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
