//
//  CartScreen.swift
//  StyleEaseApp
//

import SwiftUI
import SDWebImageSwiftUI

struct CartScreen: View {
    
    @State var products = [ProductDataModel]()
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            if products.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "cart.fill.badge.minus")
                        .font(.largeTitle)
                        .foregroundColor(.red.opacity(0.5))
                    Text("The cart is currently empty. Kindly add products to proceed with checkout.")
                        .font(.headline)
                        .foregroundColor(.red.opacity(0.5))
                    Spacer()
                }
                .padding()
            } else {
                VStack {
                    List {
                        ForEach(products) { product in
                            NavigationLink(destination: ProductDetailScreen(product: product)) {
                                ProductCartListCell(product: product)
                            }
                        }
                        .onDelete(perform: deleteProducts)
                    }
                    .listStyle(InsetListStyle())
                    
                    
                    Spacer()
                    
                    if !products.isEmpty {
                        NavigationLink {
                            CheckoutScreen(products: $products)
                        } label: {
                            Text("Proceed to Checkout")
                                .padding()
                                .frame(width: UIScreen.main.bounds.width)
                                .bold().monospaced()
                                .font(.footnote)
                                .foregroundStyle(.white)
                                .background(.green)
                            
                        }
                    }
                }
                .padding(.bottom,2)
                .navigationBarTitle("My Cart")
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(title),
                        message: Text(message),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .toolbar(.visible, for: .navigationBar)
            }
            
        }
        .onAppear {
            getCartProducts()
        }
    }
    
    private func getCartProducts() {
        FirebaseQueryManager.shared.getCartProducts { result in
            switch result {
            case .success(let cartProducts):
                self.products = cartProducts
            case .failure(let error):
                showAlert = true
                title = "Error"
                message = "Error retrieving cart products: \(error)"
            }
        }
    }
    
    private func deleteProducts(at indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let propertyId = products[index].id
        
        FirebaseQueryManager.shared.removeFromCart(productIDs: [propertyId]) { error in
            if let error = error {
                title = "Error"
                message = "Error removing from cart: \(error)"
            } else {
                products.remove(atOffsets: indexSet)
                title = "Success"
                message = "Product removed from the cart successfully"
            }
        }
        
    }
}

struct ProductCartListCell: View {
    var product: ProductDataModel
    @State private var price = 0
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
                    Text("Size: \(product.size)").fontWeight(.semibold)
                        .foregroundStyle(.white)
                    Spacer()
                }
                HStack {
                    Text("Quantity: \(product.quantity)")
                        .foregroundStyle(.white)
                        .font(.footnote)
                    Spacer()
                }
                HStack {
                    Text("Price: $\(price)")
                        .foregroundStyle(.white)
                        .font(.footnote)
                    Spacer()
                }
            }
            .padding(8)
        }
        .background(.red)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            if let _price = Int(product.price), let quantity = Int(product.quantity) {
                self.price = _price * quantity
            }
            
        }
    }
}
