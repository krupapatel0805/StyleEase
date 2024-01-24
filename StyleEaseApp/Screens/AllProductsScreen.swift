//
//  AllProductsScreen.swift
//  StyleEaseApp
//

import SwiftUI
import SDWebImageSwiftUI
//@available(iOS 17.0, *)
struct AllProductsScreen: View {
    
    @State private var filteredProducts = [ProductDataModel]()
    @Binding var products: [ProductDataModel]
    @State private var selectedFilter: String? = nil
    @State private var isFilterMenuPresented: Bool = false
    var selectedCategory: String = ""
    
    
    var body: some View {
        VStack {
            List(filteredProducts, id: \.id) { product in
                NavigationLink(destination: ProductDetailScreen(product: product)) {
                    ProductViewListCell(product: product)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle(selectedCategory)
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isFilterMenuPresented = true
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                    .actionSheet(isPresented: $isFilterMenuPresented) {
                        ActionSheet(title: Text("Filter by"), buttons: [
                            .default(Text("Formal Shirts")) { selectedFilter = "Formal Shirts" },
                            .default(Text("Pants")) { selectedFilter = "Pants" },
                            .default(Text("Shoes")) { selectedFilter = "Shoes" },
                            .default(Text("Casual Shirts")) { selectedFilter = "Casual Shirts" },
                            .cancel()
                        ])
                    }
                }
            }
            .onChange(of: selectedFilter, {
                updateProducts()
            })
            .onAppear {
                updateProducts()
            }
        }
    }
    
    private func updateProducts() {
        var filtered = products
        
        if !selectedCategory.isEmpty {
            filtered = filtered.filter {
                $0.category == selectedCategory
            }
        }
        
        if let filter = selectedFilter, !filter.isEmpty {
            filtered = filtered.filter {
                $0.subCategory == filter
            }
        }
        
        self.filteredProducts = filtered
    }
    
}

struct ProductViewListCell: View {
    var product: ProductDataModel
    var body: some View {
        VStack {
            WebImage(url: URL(string: product.imageUrl)!)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .frame(maxWidth: UIScreen.main.bounds.width)
                .clipped()

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
//                    Text("Sold: \(product.sold)")
//                        .foregroundStyle(.white)
//                        .font(.footnote)
                }
            }
            .padding(8)
            
        }
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
