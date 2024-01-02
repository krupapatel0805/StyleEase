//
//  DetailsScreen.swift
//  StyleEase
//
//  Created by Sam 77 on 2023-12-26.
//

import Foundation
import SwiftUI

struct DetailScreen: View {
    @State private var confirmationAlert = false
    @ObservedObject var cartManager = CartManager()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let product: Product // Assuming the product details are passed here
    @State private var selectedSizeIndex = 0 // Track the selected size index
    @State private var selectedColor: ColorOption? = nil // Track the selected color
    @State private var isExpanded: Bool = false

    var body: some View {
        ZStack {
            Color("Bg")
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Image(product.imageName)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .edgesIgnoringSafeArea(.top)

                    Text(product.name)
                        .font(.title)
                        .fontWeight(.bold)

                    DisclosureGroup(
                        isExpanded: $isExpanded,
                        content: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Article number: \(product.code)")
                                Text("Name: \(product.name)")
                                Text("\(product.description)")
                                Text("Length: \(product.length)")
                                Text("Fit: \(product.fit)")
                                Text("Style: \(product.style)")
                                Text("Pattern: \(product.pattern)")
                            }
                            .padding(.horizontal)
                        },
                        label: {
                            Text("Descriptions and Fits")
                                .fontWeight(.medium)
                        }
                    )
                    .padding(.vertical, 8)

                    DisclosureGroup(
                        isExpanded: $isExpanded,
                        content: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Material: \(product.material)")
                                Text("Graphical Appereance: \(product.graphicalAppereance)")
                                Text("Lining: \(product.description) \(product.liningPercentage)")
                                Text("Shell: \(product.length) \(product.shellPercentage)")

                                Text("The total weight of the product is calculated by adding the weight of all layers and main components together. All the materials are original and organic.")
                                    .font(.system(size: 14, weight: .light))
                            }
                            .padding(.horizontal)
                        },
                        label: {
                            Text("Materials and Compositions")
                                .fontWeight(.medium)
                        }
                    )
                    .padding(.vertical, 8)

                    Text("Sizes")
                        .font(.headline)

                    Spacer()

                    Picker(selection: $selectedSizeIndex, label: Text("Size")) {
                        ForEach(0..<product.size.availableSizes.count, id: \.self) { index in
                            Text(product.size.availableSizes[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Text("Colors:")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(product.colors, id: \.name) { color in
                                Button(action: {
                                    selectedColor = color // Set the selected color
                                }) {
                                    Circle()
                                        .fill(Color(color.hexCode))
                                        .frame(width: 24, height: 24)
                                        .overlay(Circle().stroke(selectedColor?.name == color.name ? Color.blue : Color.secondary, lineWidth: 2))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    HStack {
                        Text("$\(product.price)")
                            .font(.title)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            guard let selectedColor = selectedColor,
                                    let selectedSize = product.size.availableSizes[safe: selectedSizeIndex] else {
                                  // Handle invalid selection, e.g., show an alert
                                  return
                              }

                            cartManager.addToCart(product: product, selectedColor: selectedColor, selectedSize: selectedSize)
                            confirmationAlert.toggle()
                        }) {
                            Text("Add to Cart")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("Primary"))
                                .padding()
                                .padding(.horizontal, 8)
                                .background(Color.white)
                                .cornerRadius(10.0)
                        }
                    }
                }
                .padding()
                .padding(.top)
                .background(Color("Bg"))
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .offset(x: 0, y: -30.0)
                .edgesIgnoringSafeArea(.top)
                .padding()
                .padding(.horizontal)
                .background(Color("Primary"))
                .cornerRadius(60.0, corners: .topLeft)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: BackButton(),
            trailing: Button(action: { self.shareProduct() }) {
                Image("threeDot")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        )
        .alert(isPresented: $confirmationAlert) {
            Alert(title: Text("Product Added to Cart"),
                  message: Text("The selected product has been added to your cart."),
                  dismissButton: .default(Text("OK")))
        }
    }
}

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.black)
                .padding(.all, 12)
                .background(Color.white)
                .cornerRadius(8.0)
        }
    }
}


//For sharing the product(three dots)
extension View {
    func shareProduct() {
        // Define the item you want to share (e.g., a product URL)
        let productURL = URL(string: "https://your-product-url.com")!

        // Create an instance of UIActivityViewController to share the product URL
        let activityViewController = UIActivityViewController(activityItems: [productURL], applicationActivities: nil)

        // Present the share sheet
        if let viewController = UIApplication.shared.windows.first?.rootViewController {
            viewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

struct DetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        DetailScreen()
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
