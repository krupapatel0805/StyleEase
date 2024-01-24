//
//  MyOrdersScreen.swift
//  StyleEaseApp
//
//  Created by Macbook on 13/01/2024.
//

import SwiftUI
import StarRating

struct MyOrdersScreen: View {
    
    @State private var orders = [OrderInfoDataModel]()
    
    var body: some View {
        NavigationView {
            VStack {
                if orders.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "bag.fill.badge.minus")
                            .font(.largeTitle)
                            .foregroundColor(.red.opacity(0.5))
                        Text("You haven't made any orders yet.")
                            .font(.headline)
                            .foregroundColor(.red.opacity(0.5))
                        Spacer()
                    }
                } else {
                    
                    List {
                        ForEach(orders) { order in
                            NavigationLink(destination: DeliveredOrderScreen(order: order)) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Status: ")
                                            .font(.headline)
                                        Text(orderStatus(for: convertToDate(from: order.orderDate) ?? Date()))
                                            .font(.headline)
                                        Spacer()
                                    }
                                    
                                    Text("Order Number: \(order.orderSKU)")
                                        .foregroundColor(.secondary)
                                    
                                    Text("Amount: $\(order.amount)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                    }
                    .listStyle(InsetListStyle())
                    
                }
            }
            .navigationTitle("My Orders")
        }
        .onAppear {
            FirebaseQueryManager.shared.getOrders() { result in
                switch result {
                case .success(let orders):
                    self.orders = orders
                    print("Orders: \(orders)")
                case .failure(let error):
                    print("Error retrieving orders: \(error)")
                }
            }
        }
    }
    func convertToDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.date(from: dateString)
    }
    func orderStatus(for orderDate: Date) -> String {
        let calendar = Calendar.current
        let currentDate = Date()
        
        if calendar.isDateInToday(orderDate) {
            return "Order In-Process"
        } else if calendar.isDateInYesterday(orderDate) {
            return "Order Dispatched"
        } else if let daysAgo = calendar.dateComponents([.day], from: orderDate, to: currentDate).day, daysAgo == 2 {
            return "Order Delivered"
        } else {
            return "Order Status Unknown"
        }
    }
}


struct DeliveredOrderScreen: View {
    var order: OrderInfoDataModel
    @State private var products = [ProductDataModel]()
    var body: some View {
        VStack {
            List {
                ForEach(products) { product in
                    NavigationLink(destination: RateProductScreen(product: product, orderSKU: order.orderSKU)) {
                        VStack {
                            HStack {
                                Text("Product Name: ")
                                    .foregroundColor(.gray)
                                Text(product.name)
                                    .foregroundColor(.gray)
                                    .font(.headline)
                                Spacer()
                            }
                            
                            HStack {
                                Text("Price: $")
                                    .foregroundColor(.gray)
                                Text(product.price)
                                    .foregroundColor(.gray)
                                    .font(.headline)
                                Spacer()
                            }
                        }
                    }
                }
                
            }
            .listStyle(InsetListStyle())
        }
        .onAppear {
            FirebaseQueryManager.shared.getProductsWithIDs(withProductIDs: order.products) { result in
                switch result {
                case .success(let products):
                    print("Filtered Products: \(products)")
                    self.products = products
                case .failure(let error):
                    print("Error fetching filtered products: \(error)")
                }
            }
        }
        .navigationTitle("Order Information")
    }
}

struct RateProductScreen: View {
    var product: ProductDataModel
    var orderSKU: String
    
    @State private var reviewText = ""
    @State private var alertMessage = ""
    @State private var customConfig = StarRatingConfiguration(numberOfStars: 5, minRating: 1)
    @State private var rating: Double = 1
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Write your review")
                    .font(.title).monospaced()
                    .bold()
                    .foregroundStyle(.red)
                    .padding()
                
                TextEditor(text: $reviewText)
                    .padding(4)
                    .frame(maxHeight: 100)
                    .border(Color.gray, width: 1)
                    .padding()

                
                StarRating(initialRating: rating, onRatingChanged: {
                    rating = $0
                }).frame(width: 300, height: 100)
                
                Button(action: {
                    self.submitReview()
                }) {
                    Text("Submit Review")
                        .font(.title3)
                        .padding()
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Alert"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                FirebaseQueryManager.shared.checkIfReviewExists(orderSKU: orderSKU, productId: product.id) { result in
                    switch result {
                    case .success(let review):
                        self.reviewText = review?.review ?? ""
                        self.rating = review?.rating ?? 1.0
                    case .failure(let error):
                        print("Error retrieving reviews: \(error)")
                    }
                }
            }
        }
    }
    
    private func submitReview() {
        let date = formatDateToString(Date())
        if reviewText.isEmpty {
            showAlert = true
            alertMessage = "Review field is missing, we appreciate your review"
            return
        }
        let review = ReviewDataModel(productId: product.id, 
                                     review: reviewText,
                                     date: date,
                                     orderSKU: orderSKU,
                                     rating: rating)
        FirebaseQueryManager.shared.addReview(review: review) { err in
            if err == nil {
                showAlert = true
                alertMessage = "Thank you for your review"
            }
        }
    }
    
}
func formatDateToString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy"
    return dateFormatter.string(from: date)
}
