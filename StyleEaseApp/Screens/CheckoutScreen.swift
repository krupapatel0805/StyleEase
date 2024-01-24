//
//  CheckoutScreen.swift
//  StyleEaseApp
//
//  Created by Macbook on 13/01/2024.
//
import SwiftUI

struct CheckoutScreen: View {
    
    @Binding var products: [ProductDataModel]
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var country: String = ""
    @State private var streetAddress: String = ""
    @State private var area: String = ""
    @State private var postalCode: String = ""
    @State private var paymentMethod = "Cash on Delivery"
    
    @State private var cardHolderName = ""
    @State private var cardNumber = ""
    @State private var expMonth = ""
    @State private var expYear = ""
    @State private var cvc = ""
    @State private var dateString = ""
    
    @State private var isCardHolderNameValid = false
    @State private var isCardNumberValid = false
    @State private var isExpMonthValid = false
    @State private var isExpYearValid = false
    @State private var isCvcValid = false
    
    @State private var isDatePickerVisible = false
    @State private var selectedDate = Date()
    
    @State private var showAlert = false
    @State private var isProcessing = false
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""
    
    @State var totalAmount = 0
    @State var productIds = [String]()
    
    var body: some View {
        List {
            personalInformationSection
            shippingAddressSection
            billingDetailsSection
            if paymentMethod == "Debit/Credit Card" {
                cardInformationSection
                if isDatePickerVisible {
                    datePickerView
                    datePickerDoneButton
                }
            }
            placeOrderSection
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage))
        }
        .onAppear {
            for product in products {
                guard let price = Int(product.price) else {return}
                guard let quantity = Int(product.quantity) else {return}
                totalAmount += price * quantity
            }
            productIds = products.map { $0.id }
        }
        .navigationTitle("Checkout")
    }
    
    private var personalInformationSection: some View {
        Section(header: Text("Personal Information")) {
            TextField("Name", text: $name)
            TextField("Email", text: $email)
            TextField("Phone", text: $phone)
        }
    }

    private var shippingAddressSection: some View {
        Section(header: Text("Shipping Address"), footer: Text("Ensure that you provide the correct address to prevent any inconvenience.")) {
            TextField("Country", text: $country)
            TextField("Area", text: $area)
            TextField("Street", text: $streetAddress)
            TextField("Postal Code", text: $postalCode)
        }
    }

    private var billingDetailsSection: some View {
        Section(header: Text("Billing Details")) {
            Picker("Payment Method", selection: $paymentMethod) {
                Text("Cash on Delivery").tag("Cash on Delivery")
                Text("Debit/Credit Card").tag("Debit/Credit Card")
            }
            .pickerStyle(MenuPickerStyle())
        }
    }

    private var cardInformationSection: some View {

        Section(header: Text("Card Information")) {
            TextField("Cardholder Name", text: $cardHolderName)
                .onChange(of: cardHolderName) { newValue in
                    isCardHolderNameValid = !newValue.isEmpty
                }
            
                .foregroundColor(isCardHolderNameValid ? .primary : .red)
            
            TextField("Card Number", text: $cardNumber)
                .keyboardType(.numberPad)
                .onChange(of: cardNumber) { newValue in
                    isCardNumberValid = isValidCardNumber(newValue)
                }
                .foregroundColor(isCardNumberValid ? .primary : .red)
            
            HStack {
                TextField("Exp Month (MM)", text: $expMonth)
                    .keyboardType(.numberPad)
                    .onChange(of: expMonth) { newValue in
                        isExpMonthValid = isValidExpDate(newValue)
                    }
                    .foregroundColor(isExpMonthValid ? .primary : .red)
                
                Spacer(minLength: 20)
                
                TextField("Exp Year (YY)", text: $expYear )
                    
                    .keyboardType(.numberPad)
                    .onChange(of: expYear) { newValue in
                        isExpYearValid = isValidExpDate(newValue)
                    }
                    .foregroundColor(isExpYearValid ? .primary : .red)
            }
            
            TextField("CVC", text: $cvc)
                .keyboardType(.numberPad)
                .onChange(of: cvc) { newValue in
                    isCvcValid = isValidCVC(newValue)
                }
                .foregroundColor(isCvcValid ? .primary : .red)
        }
    }
    
    private var datePickerView: some View {
        DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
            .datePickerStyle(CompactDatePickerStyle())
            .labelsHidden()
            .padding()
    }
    
    private var datePickerDoneButton: some View {
        Button("Done") {
            isDatePickerVisible = false
            dateString = getFormattedDate()
        }
        .padding()
        .foregroundColor(.blue)
    }

    private var placeOrderSection: some View {
        Section {
            HStack {
                Spacer()
                Button(action: {
                    placeOrder()
                }, label: {
                    Text("Place Order $\(totalAmount)")
                        .font(.body)
                })
                .disabled(isProcessing)
                .overlay(
                    isProcessing  ? ProgressView().foregroundStyle(.black) : nil
                )
                Spacer()
            }
        }
    }
    
    private func placeOrder() {
        guard isPersonalInformationValid,
              isShippingAddressValid,
              isCardInformationValid else {
            showAlert = true
            alertMessage = "Please fill out all required fields correctly."
            return
        }
        
        if totalAmount == 0 {
            showAlert = true
            alertMessage = "Invalid order amount"
            return
        }
        
        isProcessing = true
        let totalAmount = Int(self.totalAmount)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateString = dateFormatter.string(from: Date())
        let orderData = OrderInfoDataModel(name: name, email: email, phone: phone, country: country, streetAddress: streetAddress, area: area, postalCode: postalCode, paymentMethod: paymentMethod, amount: "\(totalAmount)", products: self.productIds, orderDate: dateString, orderSKU: generateRandomString())
        
        FirebaseQueryManager.shared.placeOrder(orderInfo: orderData) { error in
            isProcessing = false
            showAlert = true
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "Order placed successfully"
                emptyCart()
                addNotification(order: orderData)
            }
        }
        
    }
    
    private func emptyCart() {
        FirebaseQueryManager.shared.removeFromCart(productIDs: self.productIds) { error in
            showAlert = true
            if let _ = error {} else {products.removeAll()}
        }
    }
    
//    private func addNotification(order: OrderInfoDataModel) {
//        let title = "A Payment of $\(order.amount) has been deducted and order number \(order.orderSKU) has been placed and will be shipped soon."
//        let notification = NotificationDataModel(notification: title, orderSKU: order.orderSKU, date: order.orderDate)
//        FirebaseQueryManager.shared.addNotification(notificationInfo: notification) { _ in }
//    }
    
    private func addNotification(order: OrderInfoDataModel) {
        var title: String
        
        switch order.paymentMethod {
        case "Cash on Delivery":
            title = "Your order \(order.orderSKU) has been placed successfully and will be shipped soon. Payment will be collected upon delivery."
        case "Debit/Credit Card":
            title = "A payment of $\(order.amount) for order \(order.orderSKU) has been successfully processed, and the order will be shipped soon."
        default:
            title = "Order \(order.orderSKU) has been placed successfully."
        }
        
        let notification = NotificationDataModel(notification: title, orderSKU: order.orderSKU, date: order.orderDate)
        
        FirebaseQueryManager.shared.addNotification(notificationInfo: notification) { _ in }
    }

    
    private var isPersonalInformationValid: Bool {
        return !name.isEmpty && !email.isEmpty && !phone.isEmpty
    }
    
    private var isShippingAddressValid: Bool {
        return !country.isEmpty && !area.isEmpty && !streetAddress.isEmpty && !postalCode.isEmpty
    }
    
    private var isCardInformationValid: Bool {
        if paymentMethod == "Debit/Credit Card" {
            return isCardHolderNameValid && isCardNumberValid && isExpMonthValid && isExpYearValid && isCvcValid
        } else {
            return true
        }
    }

    private func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: selectedDate)
    }

    private func isValidCardNumber(_ cardNumber: String) -> Bool {
        return cardNumber.isNumeric && cardNumber.count == 16
    }

    private func isValidExpDate(_ expDate: String) -> Bool {
        return expDate.isNumeric && expDate.count == 2
    }

    private func isValidCVC(_ cvc: String) -> Bool {
        return cvc.isNumeric && cvc.count == 3
    }
}
