//
//  AddProductScreen.swift
//  StyleEaseApp
//
//  Created by Macbook on 13/01/2024.
//

import SwiftUI



struct AddProductScreen: View {
    
    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    
    @State private var categoryType = "Men"
    @State private var subCategoryType = "Formal Shirts"
    
    @State private var selectedImages: [UIImage] = []
    @State private var isImagePickerPresented: Bool = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var isLoading = false
    
    var body: some View {
        
        ZStack {
            VStack {
                Form {
                    Section(header: Text("Product Details")) {
                        TextField("Name", text: $name)
                        TextField("Description", text: $description)
                        TextField("Price", text: $price)
                            .keyboardType(.numberPad)
                    }
                    
                    Section(header: Text("Category"))  {
                        Picker("Category", selection: $categoryType) {
                            Text("Men").tag("Men")
                            Text("Women").tag("Women")
                            Text("Children").tag("Children")
                            Text("Unisex").tag("Unisex")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Section(header: Text("Sub Category"))  {
                        Picker("Category", selection: $subCategoryType) {
                            Text("Formal Shirts").tag("Formal Shirts")
                            Text("Pants").tag("Pants")
                            Text("Shoes").tag("Shoes")
                            Text("Casual Shirts").tag("Casual Shirts")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Section(header: Text("Product Image")) {
                        
                        Button("Add Images") {
                            isImagePickerPresented.toggle()
                        }
                        
                        if !self.selectedImages.isEmpty {
                            CustomImageView(image: self.selectedImages.last!)
                                .frame(width: 140, height: 140)
                                .cornerRadius(10)
                        }
                        
                        
                    }
                    
                    Section {
                        Button(action: {
                            if isValidInput() {
                                addProduct()
                            }
                        }, label: {
                            Text("Add Product")
                        })
                        .disabled(isLoading)
                        .overlay(
                            isLoading ? ProgressView() : nil
                        )
                    }
                }
                
            }
        }
        .navigationTitle("Add New Product")
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImages: $selectedImages)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func isValidInput() -> Bool {
        if name.isEmpty {
            showAlert = true
            alertMessage = "Please enter a name."
            return false
        }

        if description.isEmpty {
            showAlert = true
            alertMessage = "Please enter a description."
            return false
        }

        if price.isEmpty {
            showAlert = true
            alertMessage = "Please enter a price."
            return false
        }
        
        if let priceInt = Int(price) {
            if !priceInt.isValidPrice() {
                showAlert = true
                alertMessage = "Please enter a valid price."
                return false
            }
        } else {
            showAlert = true
            alertMessage = "Please enter a valid price."
            return false
        }
        

        if selectedImages.isEmpty {
            showAlert = true
            alertMessage = "Please select an image."
            return false
        }

        return true
    }

    
    private func clearFields() {
        name = ""
        description = ""
        price = ""
        selectedImages.removeAll()
    }
    
    private func addProduct() {
        isLoading = true
        guard let image = self.selectedImages.last else {return}
        FirebaseQueryManager.shared.uploadData(image: image) { imageURL, error in
            if error == nil {
                
                let product = ProductDataModel(category: categoryType, description: description, imageUrl: imageURL?.absoluteString ?? "", sold: 0, subCategory: subCategoryType, price: price.removingLeadingZeros(), name: name, size: "", quantity: "")
                FirebaseQueryManager.shared.addProduct(product: product, imageUrl: imageURL?.absoluteString ?? "") { err in
                    if err == nil {
                        isLoading = false
                        showAlert = true
                        if let error = error {
                            alertMessage = "\(error.localizedDescription)"
                        } else {
                            alertMessage = "Product added successfully"
                        }
                    }
                }
            }
        }
    }
}


struct SelectedImagesView: View {
    
    @Binding var selectedImages: [UIImage]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollView in
                HStack(spacing: 20) {
                    ForEach(selectedImages, id: \.self) { image in
                        CustomImageView(image: image)
                            .frame(width: 140, height: 140)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}
#Preview {
    AddProductScreen()
}

struct CustomImageView: View{
    var image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .cornerRadius(10)
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.presentationMode) private var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImages.append(editedImage)
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImages.append(originalImage)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
