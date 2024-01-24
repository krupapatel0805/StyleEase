//
//  FirebaseQueryManager.swift
//  StyleEaseApp
//
//  Created by Macbook on 12/01/2024.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseStorage

class FirebaseQueryManager {
    
    static let shared = FirebaseQueryManager()
    private init() {}
    
    func getUserInfo(completion: @escaping (Bool) -> Void) {
        guard let userId = StorageManager.shared.userId else {return}
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")

        usersCollection.document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error)")
                return
            }
            if let userData = document?.data() {
                StorageManager.shared.email = userData["email"] as? String ?? ""
                StorageManager.shared.name = userData["name"] as? String ?? ""
                StorageManager.shared.phone = userData["phone"] as? String ?? ""
                completion(true)
            } else {
                print("User document not found")
            }
        }
    }
    
    func updateUserInfo(name: String, phone: String, completion: @escaping (Bool, String) -> Void) {
        guard let userId = StorageManager.shared.userId else {
            completion(false, "")
            return
        }

        let db = Firestore.firestore()
        let usersCollection = db.collection("users")

        let updatedData: [String: Any] = [
            "name": name,
            "phone": phone
        ]

        usersCollection.document(userId).updateData(updatedData) { error in
            if let error = error {
                print("Error updating user document: \(error)")
                completion(false, error.localizedDescription)
            } else {
                StorageManager.shared.name = name
                StorageManager.shared.phone = phone
                completion(true, "Record Updated Successfully")
            }
        }
    }

    
    func getAllProducts(completion: @escaping (Result<[ProductDataModel], Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("products").getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                do {
                    let properties = try querySnapshot?.documents.compactMap { document -> ProductDataModel? in
                        let property = try document.data(as: ProductDataModel.self)
                        return property
                    } ?? []
                    completion(.success(properties))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func addToCart(productID: String, size: String, quantity:String, completion: @escaping (Error?) -> Void) {
        
        guard let userId = StorageManager.shared.userId else {return}
        let db = Firestore.firestore()
        
        let cartData: [String: Any] = [
            "productID": productID,
            "userID": userId,
            "size": size,
            "quantity": quantity
        ]
        
        db.collection("cart").addDocument(data: cartData) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func checkProductInCart(productID: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = StorageManager.shared.userId else {
            completion(false, nil)
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("cart")
            .whereField("productID", isEqualTo: productID)
            .whereField("userID", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                let productInCart = querySnapshot?.documents.isEmpty == false
                completion(productInCart, nil)
            }
    }
    
    func removeFromCart(productIDs: [String], completion: @escaping (Error?) -> Void) {
        guard let userId = StorageManager.shared.userId else {
            return
        }

        let db = Firestore.firestore()

        db.collection("cart")
            .whereField("userID", isEqualTo: userId)
            .whereField("productID", in: productIDs)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(error)
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    completion(nil)
                    return
                }

                let batch = db.batch()

                for document in documents {
                    batch.deleteDocument(document.reference)
                }

                batch.commit { batchError in
                    completion(batchError)
                }
            }
    }

    func getCartProducts(completion: @escaping (Result<[ProductDataModel], Error>) -> Void) {
        guard let userId = StorageManager.shared.userId else {return}
        
        let db = Firestore.firestore()
        db.collection("cart")
            .whereField("userID", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let productIDs = querySnapshot?.documents.map { $0["productID"] as? String ?? "" } ?? []
                let sizes = querySnapshot?.documents.map { $0["size"] as? String ?? "" } ?? []
                let quantities = querySnapshot?.documents.map { $0["quantity"] as? String ?? "" } ?? []
                
                self.getAllProducts { result in
                    switch result {
                    case .success(let allProducts):
                        var cartProducts = allProducts.filter { product in
                            productIDs.contains(product.id)
                        }
                        for i in 0..<cartProducts.count {
                            cartProducts[i].size = sizes[i]
                            cartProducts[i].quantity = quantities[i]
                        }
                        completion(.success(cartProducts))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
    
    func placeOrder(orderInfo: OrderInfoDataModel, completion: @escaping (Error?) -> Void) {
        guard let userId = StorageManager.shared.userId else {
            completion(nil)
            return
        }

        let db = Firestore.firestore()
        let ordersCollection = db.collection("orders")

        var orderInfoDict = orderInfo.asDictionary
        orderInfoDict["userId"] = userId

        ordersCollection.addDocument(data: orderInfoDict) { error in
            completion(error)
        }
    }

    func addNotification(notificationInfo: NotificationDataModel, completion: @escaping (Error?) -> Void) {
        guard let userId = StorageManager.shared.userId else {
            completion(nil)
            return
        }
        let db = Firestore.firestore()
        let notificationsCollection = db.collection("notifications")

        var notificationDict = notificationInfo.asDictionary
        notificationDict["userId"] = userId
        notificationsCollection.addDocument(data: notificationDict) { error in
            completion(error)
        }
    }

    func getNotifications(completion: @escaping (Result<[NotificationDataModel], Error>) -> Void) {
        guard let userId = StorageManager.shared.userId else {
            return
        }
        let db = Firestore.firestore()
        let notificationsCollection = db.collection("notifications")

        // Query notifications for the specific userId
        notificationsCollection
            .whereField("userId", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                do {
                    let notifications = try querySnapshot?.documents.compactMap { document -> NotificationDataModel? in
                        let notification = try document.data(as: NotificationDataModel.self)
                        return notification
                    } ?? []

                    completion(.success(notifications))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    func getOrders(completion: @escaping (Result<[OrderInfoDataModel], Error>) -> Void) {
        guard let userId = StorageManager.shared.userId else {
            return
        }
        let db = Firestore.firestore()
        let ordersCollection = db.collection("orders")

        ordersCollection
            .whereField("userId", isEqualTo: userId)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    do {
                        let orders = try querySnapshot?.documents.compactMap { document -> OrderInfoDataModel? in
                            let order = try document.data(as: OrderInfoDataModel.self)
                            return order
                        } ?? []
                        completion(.success(orders))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
    }
    
//    func addReview(review: ReviewDataModel, completion: @escaping (Error?) -> Void) {
//        guard let userId = StorageManager.shared.userId else {
//            completion(nil)
//            return
//        }
//        let db = Firestore.firestore()
//        let reviewCollection = db.collection("reviews")
//
//        var notificationDict = review.asDictionary
//        notificationDict["userId"] = userId
//        reviewCollection.addDocument(data: notificationDict) { error in
//            completion(error)
//        }
//    }
    
    func addReview(review: ReviewDataModel, completion: @escaping (Error?) -> Void) {
        guard let userId = StorageManager.shared.userId else {
            completion(nil)
            return
        }

        let db = Firestore.firestore()
        let reviewCollection = db.collection("reviews")

        // Check if a review already exists for the given orderSKU and productId
        let query = reviewCollection
            .whereField("orderSKU", isEqualTo: review.orderSKU)
            .whereField("productId", isEqualTo: review.productId)
            .whereField("userId", isEqualTo: userId)

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
                return
            }

            // If there are no existing reviews, add the new review
            if querySnapshot?.isEmpty ?? true {
                var reviewData = review.asDictionary
                reviewData["userId"] = userId
                reviewCollection.addDocument(data: reviewData) { error in
                    completion(error)
                }
            } else {
                // If a review already exists, update the existing review data
                if let existingReviewDocument = querySnapshot?.documents.first {
                    var updatedReviewData = review.asDictionary
                    updatedReviewData["userId"] = userId
                    existingReviewDocument.reference.setData(updatedReviewData, merge: true) { error in
                        completion(error)
                    }
                } else {
                    // Handle the case where there is an existing review but failed to update it
                    let updateError = NSError(domain: "Firestore", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error updating existing review"])
                    completion(updateError)
                }
            }
        }
    }

    
    func getProductsWithIDs(withProductIDs productIDs: [String], completion: @escaping (Result<[ProductDataModel], Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("products")
            .whereField("id", in: productIDs)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    do {
                        let properties = try querySnapshot?.documents.compactMap { document -> ProductDataModel? in
                            let property = try document.data(as: ProductDataModel.self)
                            return property
                        } ?? []
                        completion(.success(properties))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
    }
    

    func checkIfReviewExists(orderSKU: String, productId: String, completion: @escaping (Result<ReviewDataModel?, Error>) -> Void) {
        guard let userId = StorageManager.shared.userId else {
            completion(.failure(NSError(domain: "Firestore", code: 400, userInfo: [NSLocalizedDescriptionKey: "User ID is nil"])))
            return
        }

        let db = Firestore.firestore()
        let reviewCollection = db.collection("reviews")

        // Check if a review already exists for the given orderSKU, productId, and userId
        let query = reviewCollection
            .whereField("orderSKU", isEqualTo: orderSKU)
            .whereField("productId", isEqualTo: productId)
            .whereField("userId", isEqualTo: userId)

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            // If there are no existing reviews, return nil
            if querySnapshot?.isEmpty ?? true {
                completion(.success(nil))
            } else {
                do {
                    let reviews = try querySnapshot?.documents.compactMap { document -> ReviewDataModel? in
                        let review = try document.data(as: ReviewDataModel.self)
                        return review
                    } ?? []
                    completion(.success(reviews.first))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    
    
    
    func getReviews(forProductIds productIds: [String], completion: @escaping (Result<[ReviewDataModel], Error>) -> Void) {
        let db = Firestore.firestore()
        let reviewCollection = db.collection("reviews")

        reviewCollection
            .whereField("productId", isEqualTo: productIds.first!)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    do {
                        let reviews = try querySnapshot?.documents.compactMap { document -> ReviewDataModel? in
                            let review = try document.data(as: ReviewDataModel.self)
                            return review
                        } ?? []
                        completion(.success(reviews))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    func uploadData(image: UIImage, completion: @escaping (URL?, Error?) -> Void) {
        let storage = Storage.storage()
        let imageId = UUID().uuidString
        let storageRef = storage.reference().child("productImages").child("\(imageId).jpg")

        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil, NSError(domain: "RealtyPro", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data."]))
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                        completion(nil, error)
                    } else if let downloadURL = url {
                        completion(downloadURL, nil)
                    }
                }
            }
        }
    }
    
    func addProduct(product: ProductDataModel, imageUrl: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let productsCollection = db.collection("products")
        
        var productData = product.asDictionary
        productData["imageUrl"] = imageUrl
        
        productsCollection.addDocument(data: productData) { error in
            completion(error)
        }
    }
    
    
    func getUserInfoByID(userId: String, completion: @escaping (Result<UserDataModel, Error>) -> Void) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")

        usersCollection.document(userId).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let userData = document?.data() {
                let name = userData["name"] as? String ?? ""
                let email = userData["email"] as? String ?? ""
                let phone = userData["phone"] as? String ?? ""
                
                let userInfo = UserDataModel(name: name, email: email, phone: phone)
                completion(.success(userInfo))
            } else {
                let notFoundError = NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "User document not found"])
                completion(.failure(notFoundError))
            }
        }
    }
    
    
    
}

