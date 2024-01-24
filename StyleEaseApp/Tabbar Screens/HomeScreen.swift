//
//  HomeScreen.swift
//  StyleEaseApp
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeScreen: View {
    
    @State var products = [ProductDataModel]()
    @State var popularProducts = [ProductDataModel]()
    @State var allProducts = [ProductDataModel]()
    
    var body: some View {
        VStack {
            
            SearchProductsView(products: $allProducts)
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack {
                    CollectionsView(products: $products)
                        .padding(.top, 8)
                    
                    HStack {
                        Text("Popular Products")
                            .font(.title2)
                            .bold().monospaced()
                        Spacer()
                    }
                    
                    ProductsListingView(products: $popularProducts)
                    
                    HStack {
                        Text("Recently Added Products")
                            .font(.title2)
                            .bold().monospaced()
                        Spacer()
                    }
                    
                    ProductsListingView(products: $products)
                }
                Spacer()
            }
        }
        .padding()
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        
        .onAppear {
            getproducts()
        }
    }
    
    private func getproducts() {
        FirebaseQueryManager.shared.getAllProducts { result in
            switch result {
            case .success(let products):
                print("Products: \(products)")
                self.allProducts = products
                self.products = products
                let sortedProducts = products.sorted { $0.sold > $1.sold }
                self.popularProducts = Array(sortedProducts.prefix(4))
            case .failure(let error):
                print("Error retrieving products: \(error)")
            }
        }
    }
}

struct ProductsListingView: View {
    @Binding var products: [ProductDataModel]
    
    var body: some View {
        HStack {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(products) { product in
                    NavigationLink(destination: ProductDetailScreen(product: product)) {
                        ProductViewCell(product: product)
                    }
                }
            }
        }
    }
}

struct CollectionsView: View {
    
    @State var mainCategories: [CollectionsDataModel] = CollectionsDataModel.categories
    @Binding var products: [ProductDataModel]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollView in
                HStack(spacing: 20) {
                    ForEach(mainCategories) { col in
                        NavigationLink(destination: AllProductsScreen(products: $products,
                                                                      selectedCategory: col.name)) {
                            Text(col.name)
                                .padding(10)
                                .font(.callout).bold()
                                .foregroundStyle(.red)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.red, lineWidth: 1)
                                        .padding(1)
                                )
                        }
                        
                    }
                }
            }
        }
    }
}

#Preview {
    HomeScreen()
}

struct SearchProductsView: View {
    @Binding var products: [ProductDataModel]
    var body: some View {
        NavigationLink {
            SearchProductsScreen(products: $products)
        } label: {
            HStack() {
                Image(systemName: "magnifyingglass.circle.fill")
                    .foregroundColor(.white)
                    .font(.title2)
                    .padding(.leading)
                
                Text("Search for products")
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}


struct ProductViewCell: View {
    var product: ProductDataModel
    var body: some View {
        VStack {
            WebImage(url: URL(string: product.imageUrl)!)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .frame(maxWidth: (UIScreen.main.bounds.width / 2) - 20)
                .clipped()

            VStack {
                HStack {
                    Text(product.name).bold()
                        .foregroundStyle(.white)
                        .lineLimit(1)
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
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CollectionsDataModel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let image: Image

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CollectionsDataModel, rhs: CollectionsDataModel) -> Bool {
        return lhs.id == rhs.id
    }

    static var categories: [CollectionsDataModel] {
        return [
            CollectionsDataModel(name: "Men", image: Image("1")),
            CollectionsDataModel(name: "Women", image: Image("2")),
            CollectionsDataModel(name: "Children", image: Image("3")),
            CollectionsDataModel(name: "Unisex", image: Image("4")),
        ]
    }
    
    static var subCategories: [CollectionsDataModel] {
        return [
            CollectionsDataModel(name: "Formal Shirts", image: Image("1")),
            CollectionsDataModel(name: "Pants", image: Image("2")),
            CollectionsDataModel(name: "Shoes", image: Image("3")),
            CollectionsDataModel(name: "Casual Shirts", image: Image("4")),
        ]
    }
}
