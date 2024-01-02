//
//  HomeScreen.swift
//  StyleEase
//
//  Created by Sam 77 on 2023-12-24.
//

import Foundation
import SwiftUI

struct HomeScreen: View {
    @State private var search: String = ""
    @State private var categories: [Category] = []
    @State private var selectedCategory: Category? = nil
    @State private var products: [Product] = []
    @State private var showMenu: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(#colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1))
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(categories) { category in
                                Button(action: {
                                    selectedCategory = category
                                    filterProducts()
                                }) {
                                    Text(category.name)
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .foregroundColor(.black)
                                        .background(selectedCategory?.id == category.id ? Color.blue : Color.gray)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    AppBarView()
                    
                    TagLineView()
                        .padding()
                    
                    SearchAndScanView(search: $search)
                                        
                    OurProductView()
                        .padding()
                }
                
                VStack {
                    Spacer()
                    BottomNavBarView()
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                fetchCategories()
                fetchProducts()
            }
        }
    }
    
    //Function to fetch categories through API
    func fetchCategories() {
           // Simulated API request for fetching categories
           let sampleURL = URL(string: "https://api.example.com/categories")!
           URLSession.shared.dataTask(with: sampleURL) { data, _, error in
               if let data = data {
                   do {
                       let decodedResponse = try JSONDecoder().decode(CategoryResponse.self, from: data)
                       DispatchQueue.main.async {
                           categories = decodedResponse.categories
                       }
                   } catch {
                       print("Error decoding categories: \(error.localizedDescription)")
                   }
               } else {
                   print("Fetch categories error: \(error?.localizedDescription ?? "Unknown error")")
               }
           }.resume()
       }

    // Function to fetch products through API
       func fetchProducts() {
           guard let url = URL(string: "https://api.example.com/products") else { return }
           URLSession.shared.dataTask(with: url) { data, _, error in
               if let data = data {
                   do {
                       let decodedResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                       DispatchQueue.main.async {
                           products = decodedResponse.products
                       }
                   } catch {
                       print("Error decoding products: \(error.localizedDescription)")
                   }
               } else {
                   print("Fetch products error: \(error?.localizedDescription ?? "Unknown error")")
               }
           }.resume()
       }


    func filterProducts() {
           // Filter products based on the selected category
           if let selectedCategory = selectedCategory {
               if selectedCategory.id != "All" {
                   products = products.filter { $0.categoryId == selectedCategory.id }
               } else {
                   // Handle "All" category to show all products
                   fetchProducts() // Fetch all products again
               }
           }
       }
}
    
//    Home screen preview
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}

// Application Bar view (Logo and menu button)
struct AppBarView: View {
    
    @State private var showMenu: Bool = false

    var body: some View {
        HStack {
            Button(action: {
                showMenu.toggle()
            }) {
                Image("menu")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10.0)
            }
            .contextMenu {
                            NavigationLink(destination: HomeScreen()) {
                                Text("Home")
                            }

                            NavigationLink(destination: ShopAllScreen()) {
                                Text("Shop All")
                            }
                
                NavigationLink(destination: NotificationsScreen()) {
                    Text("Notifications")
                }
                
                NavigationLink(destination: UserProfileScreen()) {
                    Text("Account")
                }

                            // Add more NavigationLinks for other options...
                        }
            
            Spacer()
            
            Image("Logo")
                .resizable()
                .frame(width: 42, height: 42)
                .cornerRadius(5.0)
                .padding(.horizontal)
        }
    }
}


//Tag line view
struct TagLineView: View {
    var body: some View {
        Text("Create your Own ")
            .font(Font.custom("Montserrat", size: 28).weight(.bold))
            .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
            + Text("Style!")
            .font(Font.custom("Montserrat", size: 32).weight(.bold))
            .fontWeight(.bold)
            .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
    }
}


//Search and scan view ( Search and scan option)
struct SearchAndScanView: View {
    @Binding var search: String
    @State private var isSearchActive = false
    @State private var isScanActive = false
    
    var body: some View {
        HStack {
            HStack {
                NavigationLink(destination: SearchScreen(), isActive: $isSearchActive) {
                    EmptyView()
                }
                Image("search")
                    .padding(.trailing, 8)
                
                TextField("Search your style", text: $search)
                                   .onTapGesture {
                                       isSearchActive = true
                                   }
            }
            .padding(.all, 20)
            .background(Color.white)
            .cornerRadius(10.0)
            .padding(.trailing, 8)
            
            Button(action: {
                isScanActive = true
            }) {
                NavigationLink(destination: ScanScreen(), isActive: $isScanActive) {
                    Image("Scan")
                        .padding()
                        .background(Color("black"))
                        .cornerRadius(10.0)
                }
                .isDetailLink(false)
            }
        }
        .padding(.horizontal)
    }
}


// Filter view to display filters based on categories from API(different catogeries like: Men, Women,Children)
//struct FilterView: View {
//    @State private var selectedCategory = ""
//    private let categories = ["All", "Men", "Women", "Children"]
//
//    var body: some View {
//        VStack {
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    ForEach(categories, id: \.self) { category in
//                        Button(action: { selectedCategory = category }) {
//                            CategoryView(isActive: selectedCategory == category, text: category)
//                        }
//                    }
//                }
//                .padding()
//            }
//
//            Text(selectedCategory)
//                .font(.custom("Montserrat", size: 24))
//                .padding(.horizontal)
//                .multilineTextAlignment(.leading)
//
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 0) {
//                    ForEach(0 ..< 4) { i in
//                        if selectedCategory == "All" || selectedCategory == categories[i + 1] {
//                            NavigationLink(
//                                destination: DetailScreen(),
//                                label: {
//                                    ProductCardView(image: Image("clothes_\(i + 1)"), size: 210)
//                                })
//                                .navigationBarHidden(true)
//                                .foregroundColor(.black)
//                        }
//                    }
//                    .padding(.leading)
//                }
//            }
//            .padding(.bottom)
//        }
//    }
//}


// CategoryView with NavigationLink
struct CategoryView: View {
    let isActive: Bool
    let text: String
    var body: some View {
        NavigationLink(destination: DetailScreen()) { // Replace CategoryDetailScreen with the actual destination
            VStack(alignment: .leading, spacing: 0) {
                Text(text)
                    .font(.system(size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(isActive ? Color("Primary") : Color.black.opacity(0.5))
                if isActive {
                    Color("Primary")
                        .frame(width: 15, height: 2)
                        .clipShape(Capsule())
                }
            }
            .padding(.trailing)
        }
    }
}

// ProductCardView with NavigationLink
struct ProductCardView: View {
    let image: Image
    let size: CGFloat
    let product: Product // Assuming the product details are passed here

    var body: some View {
        NavigationLink(destination: DetailScreen(product: Product)) {
            VStack {
                Image(product.imageName)
                    .resizable()
                    .frame(width: size, height: 200 * (size/210))
                    .cornerRadius(20.0)
                
                Text(product.name)
                    .font(.title3)
                    .fontWeight(.bold)
                
                HStack(spacing: 2) {
                    Spacer()
                    Text("$\(product.price)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .frame(width: size)
            .padding()
            .background(Color.white)
            .cornerRadius(20.0)
        }
    }
}

//Our products view (Displaying all the products with time interval)
struct OurProductView: View {
    @State private var currentIndex: Int = 0
    let totalProducts = 4 // Replace this with the total number of products

    var body: some View {
        VStack {
            Text("Our Products")
                .font(.custom("Montserrat", size: 24))
                .padding(.horizontal)
                .multilineTextAlignment(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(products) { product in
                                    NavigationLink(
                                        destination: DetailScreen(product: product),
                                        label: {
                                            ProductCardView(product: product, size: 180)
                                        }
                                    )
                                }
                                .padding(.leading)
                            }
                            .onAppear {
                                // Start timer to scroll automatically
                                Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
                                    withAnimation {
                                        currentIndex = (currentIndex + 1) % totalProducts
                                    }
                                }
                            }
                        }
                    }
                }
            }


//Bottom bar view (Home,Favourite,Cart,User)
struct BottomNavBarView: View {
    var body: some View {
        HStack {
            BottomNavBarItem(image: Image("home"), action: {
//                 Navigate to HomeScreen
                 NavigationLink(destination: HomeScreen()) {
                     EmptyView()
                 }
            })
            BottomNavBarItem(image: Image("fav"), action: {
                // Navigate to FavoritesScreen
                NavigationLink(destination: FavoriteScreen()) {
                     EmptyView()
                 }
            })
            BottomNavBarItem(image: Image("shop"), action: {
                // Navigate to ShopScreen
                 NavigationLink(destination: CartScreen()) {
                     EmptyView()
                 }
            })
            BottomNavBarItem(image: Image("user"), action: {
                // Navigate to UserScreen
                 NavigationLink(destination: UserProfileScreen()) {
                     EmptyView()
                 }
            })
        }
        .padding()
        .background(Color.white)
        .clipShape(Capsule())
        .padding(.horizontal)
        .shadow(color: Color.blue.opacity(0.15), radius: 8, x: 2, y: 6)
    }
}


//Bottom bar navigation action
struct BottomNavBarItem: View {
    let image: Image
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            image
                .frame(maxWidth: .infinity)
        }
    }
}

