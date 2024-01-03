//
//  ProductRow.swift
//  StyleEaseApp
//
//  Created by Sam 77 on 2024-01-03.
//

import SwiftUI

struct ProductRow: View {
    @EnvironmentObject var cartManager: CartManager
    var product: Product
    
    var body: some View {
        HStack(spacing: 20) {
            Image(product.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(product.name)
                    .bold()

                Text("$\(product.price)")
            }
            
            Spacer()

            Image(systemName: "trash")
                .foregroundColor(Color(hue: 1.0, saturation: 0.89, brightness: 0.835))
                .onTapGesture {
                    cartManager.removeFromCart(product: product)
                }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ProductRow_Previews: PreviewProvider {
    static var previews: some View {
        ProductRow(product: Product(id: <#T##Int#>, name: <#T##String#>, imageName: <#T##String#>, description: <#T##String#>, size: <#T##Size#>, colors: <#T##[ColorOption]#>, price: <#T##Double#>, code: <#T##String#>, fit: <#T##String#>, length: <#T##String#>, style: <#T##String#>, pattern: <#T##String#>, material: <#T##String#>, graphicalAppereance: <#T##String#>, lining: <#T##String#>, liningPercentage: <#T##Double#>, shell: <#T##String#>, shellPercentage: <#T##Double#>))
            .environmentObject(CartManager())
    }
}
