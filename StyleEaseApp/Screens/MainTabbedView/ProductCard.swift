//
//  ProductCard.swift
//  StyleEaseApp
//
//  Created by Sam 77 on 2024-01-03.
//

import SwiftUI

struct ProductCard: View {
    @EnvironmentObject var cartManager: CartManager
    var product: Product
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottom) {
                Image(product.imageName)
                    .resizable()
                    .cornerRadius(20)
                    .frame(width: 180)
                    .scaledToFit()
                
                VStack(alignment: .leading) {
                    Text(product.name)
                        .bold()
                    
                    Text("\(product.price)$")
                        .font(.caption)
                }
                .padding()
                .frame(width: 180, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
            }
            .frame(width: 180, height: 250)
            .shadow(radius: 3)
            
            Button {
                cartManager.addToCart(product: product)
            } label: {
                Image(systemName: "plus")
                    .padding(10)
                    .foregroundColor(.white)
                    .background(.black)
                    .cornerRadius(50)
                    .padding()
            }
        }
    }
}

struct ProductCard_Previews: PreviewProvider {
    static var previews: some View {
        ProductCard(product: Product(id: <#T##Int#>, name: <#T##String#>, imageName: <#T##String#>, description: <#T##String#>, size: <#T##Size#>, colors: <#T##[ColorOption]#>, price: <#T##Double#>, code: <#T##String#>, fit: <#T##String#>, length: <#T##String#>, style: <#T##String#>, pattern: <#T##String#>, material: <#T##String#>, graphicalAppereance: <#T##String#>, lining: <#T##String#>, liningPercentage: <#T##Double#>, shell: <#T##String#>, shellPercentage: <#T##Double#>))
            .environmentObject(CartManager())
    }
}
