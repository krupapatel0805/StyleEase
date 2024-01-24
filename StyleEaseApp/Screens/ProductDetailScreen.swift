//
//  ProductDetailScreen.swift
//  StyleEaseApp
//

import SwiftUI
import SwiftUI
import SDWebImageSwiftUI

struct ProductDetailScreen: View {
    
    var product: ProductDataModel
    
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var showAlert: Bool = false
    @State private var isInCart: Bool = false
    @State private var rating: Double = 0.0
    @State var reviews = [ReviewDataModel]()
    @State private var selectedSize: String = ""
    @State private var selectedQuantity: Int = 1

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    WebImage(url: URL(string: product.imageUrl))
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 350)
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .clipped()
                        .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(product.name)
                                .bold().font(.title)
                            Spacer()
                            Text("$\(product.price)")
                                .font(.body).bold().monospaced()
                                .foregroundStyle(.green)
                        }
                        if product.subCategory == "Shoes" {
                            HStack {
                                Text("Select Size:")
                                
                                Picker("Shoe Size", selection: $selectedSize) {
                                    Text("36").tag("36")
                                    Text("37").tag("37")
                                    Text("38").tag("38")
                                    Text("39").tag("39")
                                    Text("40").tag("40")
                                    Text("41").tag("41")
                                    Text("42").tag("42")
                                    Text("43").tag("43")
                                    Text("44").tag("44")
                                }
                                .pickerStyle(MenuPickerStyle())
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                Spacer()
                            }
                        } else {
                            
                            Picker(selection: $selectedSize, label: Text("Select Size")) {
                                Text("Small").tag("Small")
                                Text("Medium").tag("Medium")
                                Text("Large").tag("Large")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        Stepper("Quantity \(selectedQuantity)", value: $selectedQuantity, in: 1...10)
                            .padding(.top, 8)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("\(Int(self.rating))")
                                .font(.body)
                                .foregroundStyle(.secondary)
                            Text("|")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            Text("\(reviews.count) Sold")
                                .font(.body)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        
                        Text(product.description)
//                            .lineLimit(4)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    
                }
                .frame(maxWidth: .infinity)
            }
            Spacer()
            HStack {
                Button(action: {
                    UpdateCart()
                }, label: {
                    Text(isInCart ? "Remove from Cart" : "Add to Cart")
                        .font(.callout)
                        .bold().monospaced()
                        .padding(8)
                        .frame(maxWidth: UIScreen.main.bounds.width - 2)
                        .foregroundStyle(.white)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                })
                
                
                NavigationLink {
                    ReviewsListScreen(reviews: $reviews)
                } label: {
                    Text("Reviews")
                        .font(.callout)
                        .bold()
                        .monospaced()
                        .padding(8)
                        .frame(maxWidth: UIScreen.main.bounds.width - 2)
                        .foregroundStyle(.white)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Product Detail")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            getProductCartStatus()
            getProductReviews()
            selectedSize = product.subCategory == "Shoes" ? "41" : "Small"
        }
    }
    

    private func getProductCartStatus() {
        FirebaseQueryManager.shared.checkProductInCart(productID: product.id) { _isInCart, error in
            if let error = error {
                showAlert = true
                title = "Error"
                message = "Error checking cart: \(error)"
            } else {
                self.isInCart = _isInCart
            }
        }
    }
    
    private func UpdateCart() {
        if isInCart {
            FirebaseQueryManager.shared.removeFromCart(productIDs: [product.id]) { error in
                showAlert = true
                if let error = error {
                    title = "Error"
                    message = "Error removing from cart: \(error)"
                } else {
                    self.isInCart = false
                    title = "Success"
                    message = "Product removed from the cart successfully"
                }
            }
        } else {
            FirebaseQueryManager.shared.addToCart(productID: product.id,
                                                  size: selectedSize,
                                                  quantity: "\(selectedQuantity)") { error in
                showAlert = true
                if let error = error {
                    title = "Error"
                    message = "Error adding to cart: \(error)"
                } else {
                    self.isInCart = true
                    title = "Success"
                    message = "Product added to cart successfully"
                }
            }
        }
    }
    
    private func getProductReviews() {
        FirebaseQueryManager.shared.getReviews(forProductIds:  [product.id]) { result in
            switch result {
            case .success(let reviews):
                self.reviews = reviews
                self.rating = self.calculateAverageRating(reviews: reviews)
                print("Reviews: \(reviews)")
            case .failure(let error):
                print("Error retrieving reviews: \(error)")
            }
        }
    }
    
    func calculateAverageRating(reviews: [ReviewDataModel]) -> Double {
        guard !reviews.isEmpty else {
            return 0.0
        }

        let totalRating = reviews.reduce(0.0) { $0 + $1.rating }
        let averageRating = totalRating / Double(reviews.count)
        
        return (averageRating * 10).rounded() / 10
    }
}

struct ReviewsListScreen: View {
    @Binding var reviews: [ReviewDataModel]
    var body: some View {
        if reviews.isEmpty {
            VStack {
                Spacer()
                Image(systemName: "exclamationmark.bubble.fill")
                    .font(.largeTitle)
                    .foregroundColor(.red.opacity(0.5))
                Text("Product has no reviews yet.")
                    .font(.headline)
                    .foregroundColor(.red.opacity(0.5))
                Spacer()
            }
        } else {
            List(reviews) { review in
                ReviewView(review: review)
            }
            .navigationTitle("Reviews")
            
        }
        
            
    }
}

struct ReviewView: View {
    
    var review: ReviewDataModel
    @State var reviewerName: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(reviewerName)
                    .font(.headline)
                Spacer()
            }
            Text("Rating: \(Int(review.rating))")
                .font(.headline)
            Text(review.review)
                .foregroundColor(.secondary)
            Text(review.date)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .onAppear {
            let id = review.userId
            FirebaseQueryManager.shared.getUserInfoByID(userId: id) { result in
                switch result {
                case .success(let userInfo):
                    print("Name: \(userInfo.name)")
                    reviewerName = userInfo.name
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
