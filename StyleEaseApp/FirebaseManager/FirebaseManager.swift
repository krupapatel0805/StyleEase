//
//  FirebaseManager.swift
//  StyleEase
//
//  Created by Sam 77 on 2023-12-24.
//

import Foundation
import FirebaseFirestore
import Firebase

class FirebaseManager {
    
    static var shared = FirebaseManager()
    let db = Firestore.firestore()
    
    // Function to fetch a specific user profile from Firestore using getDocument
    func getUserProfile(withId id: String, completion: @escaping (UserProfileData?) -> Void) {
        
        let db = Firestore.firestore()
        db.collection("userProfile").document(id).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting user profile: \(error.localizedDescription)")
                completion(nil)
            } else {
                if let document = documentSnapshot, document.exists {
                    do {
                        let userProfile = try document.data(as: UserProfileData.self)
                        AppUtility.shared.totalBalance = userProfile.balance
                        completion(userProfile)
                    } catch {
                        print("Error parsing user profile: \(error.localizedDescription)")
                        completion(nil)
                    }
                } else {
                    // Document does not exist
                    completion(nil)
                }
            }
        }
    }
    
    func fetchImageData(completion: @escaping ([ImageData]?, Error?) -> Void) {
        var imageDataArray: [ImageData] = []
        
        let db = Firestore.firestore()
        let imagesCollection = db.collection("images")
        
        imagesCollection.getDocuments { snapshot, error in
            
            
            if
                
                let error = error {
                completion(nil, error)
                return
            }
            
            if
                
                let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let filter = data["filter"] as? String
                    let imageURL = data["imageURL"] as? String
                    let location = data["location"] as? String
                    let rating = data["rating"] as? String
                    let title = data["title"] as? String
                    let favourite = data["isFavourite"] as? Bool
                    let latitude = data["latitude"] as? Double
                    let longitude = data["longitude"] as? Double
                    let description = data["description"] as? String
                    let price = data["price"] as? Int

                    let id = document.documentID
                    let image = ImageData(id: id, imageURL: imageURL ?? "", title: title ?? "", location: location ?? "", rating: rating ?? "", filter: filter ?? "", isFavourite: favourite ?? false, description: description ?? "", latitude: latitude ?? 0.0, longitude: longitude ?? 0.0, price: price ?? 0)
                    imageDataArray.append(image)
                    
                }
                
                completion(imageDataArray, nil) // Call completion block once outside the loop
            }
        }
    }
    
    func getFavorites(userID: String, targetFavoriteImageID: String, completion: @escaping ([FavoriteData]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        // Assuming your favorites collection is a subcollection within the user's document
        let favoritesCollection = db.collection("userProfile").document(userID).collection("favorites")
        
        favoritesCollection.whereField("favoriteImageID", isEqualTo: targetFavoriteImageID).getDocuments{ (snapshot, error) in
            if let error = error {
                print("Error getting favorites: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                if let snapshot = snapshot {
                    let favorites = snapshot.documents.compactMap { document -> FavoriteData? in
                        let data = document.data()
                        // Assuming FavoriteData is a struct or class representing your favorite model
                        return FavoriteData(documentID: document.documentID, favoriteImageID: (data["favoriteImageID"] as? String)!)
                    }
                    completion(favorites, nil)
                }
            }
        }
    }
    
    func getInterests(completion: @escaping ([String]?, Error?) -> Void){
        
        var interests = [String]()
        
        let db = Firestore.firestore()
        let imagesCollection = db.collection("interests")
        
        imagesCollection.getDocuments { snapshot, error in
            
            if let error = error {
                completion(nil, error)
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    if let filter = data["title"] as? String {
                        interests.append(filter)
                    }
                    
                }
                
                completion(interests, nil)
            }
        }
    }

    func addFavorite(userID: String, favoriteImageID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let favoritesCollection = db.collection("userProfile").document(userID).collection("favorites")
        
        // Data to be added to the new document
        let data: [String: Any] = [
            "favoriteImageID": favoriteImageID,
            // Add other fields as needed
        ]
        
        // Add the document to the "favourites" collection
        favoritesCollection.addDocument(data: data) { error in
            if let error = error {
                print("Error adding favorite: \(error.localizedDescription)")
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func getNotifications(userID: String, completion: @escaping ([NotificationData]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("userProfile").document(userID).collection("notifications").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting notifications: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                if let snapshot = snapshot {
                    let notifications = snapshot.documents.compactMap { document -> NotificationData? in
                        let data = document.data()
                        // Assuming FavoriteData is a struct or class representing your favorite model
                        return NotificationData(description: (data["description"] as? String ?? ""))
                    }
                    completion(notifications, nil)
                }
            }
        }
    }
    
    func fetchFavouriteList(completion: @escaping ([ImageData]?,Error?) -> Void) {
        let db = Firestore.firestore()
        let imagesCollection = db.collection("userProfile").document(AppUtility.shared.userId!).collection("favorites")
        
        imagesCollection.getDocuments { snapshot, error in
            
            
            if let error = error {
                completion([], error)
                return
            }
            var ids = [String]()
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    guard let id = data["favoriteImageID"] as? String else { continue }
                    ids.append(id)
                    
                }
            }
            if ids.count > 0 {
                self.getDataForSelectedIDs(selectedIDs: ids) { images in
                    completion(images, nil)
                }
            }
            else {
                completion([], nil)
            }
        }
    }
    
    func getDataForSelectedIDs(selectedIDs: [String], completion: @escaping ([ImageData]?) -> Void) {
        // Create a query to filter documents based on selected IDs
        let db = Firestore.firestore()
        let query = db.collection("images").whereField("id", in: selectedIDs)
        
        // Execute the query
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                completion([])
                return
            }
            
            // Process the documents
            var images: [ImageData] = []
            
            for document in snapshot?.documents ?? [] {
                do {
                    // Decode the document data into your model
                    let image = try document.data(as: ImageData.self)
                    images.append(image)
                } catch {
                    print("Error decoding document: \(error.localizedDescription)")
                }
            }
            
            // Return the array of images to the completion handler
            completion(images)
        }
    }
    
    func getAllOrders(completion: @escaping ([OrderData]?, Error?) -> Void) {
        var orders: [OrderData] = []
        
        let db = Firestore.firestore()
        let orderCollection = db.collection("userProfile").document(AppUtility.shared.userId!).collection("orders")
        
        orderCollection.getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let filter = data["filter"] as? String
                    let location = data["location"] as? String
                    let rating = data["rating"] as? String
                    let title = data["title"] as? String
                    let price = data["price"] as? Int
                    let date = data["date"] as? String
                    let id = document.documentID
                    
                    let order = OrderData(id: id, filter: filter ?? "", location: location ?? "", rating: rating ?? "", title: title ?? "", price: price ?? 0, date: date ?? "")
                    orders.append(order)
                }
                
                completion(orders, nil)
            }
        }
    }
    
    func addOrder(filter: String, location: String, rating: String, title: String, date: String, price:Int , completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let orderCollection = db.collection("userProfile").document(AppUtility.shared.userId!).collection("orders")
        
        let data: [String: Any] = [
            "filter": filter,
            "location": location,
            "rating": rating,
            "title": title,
            "date":date,
            "price": price
        ]
        
        orderCollection.addDocument(data: data) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    
    func addNotification(userID: String, notification: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let notificationsCollection = db.collection("userProfile").document(userID).collection("notifications")
        
        // Data to be added to the new document
        let data: [String: Any] = [
            "description": notification
        ]
        
        notificationsCollection.addDocument(data: data) { error in
            if let error = error {
                print("Error adding favorite: \(error.localizedDescription)")
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func updateBalance(newBalance: Int, completion: @escaping (Bool, Error?) -> Void) {
        
        let db = Firestore.firestore()
        let userProfileCollection = db.collection("userProfile")

        // Specify the document ID you want to update
        guard let documentId = AppUtility.shared.userId else {return}

        // Create a dictionary with the field you want to update and its new value
        let updateData = [
            "balance": newBalance // Replace "balance" with the actual field name and newValue with the new balance value
        ]

        // Update the document
        userProfileCollection.document(documentId).setData(updateData, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error)")
                completion(false, error)
            } else {
                completion(true, nil)
                print("Document successfully updated")
            }
        }
    }
    
    func deleteFavoriteByImageID(userID: String, favoriteImageID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let favoritesCollection = db.collection("userProfile").document(userID).collection("favorites")
        
        // Query documents where "favoriteImageID" is equal to the specified value
        let query = favoritesCollection.whereField("favoriteImageID", isEqualTo: favoriteImageID)
        
        // Get the documents that match the query
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error querying favorites: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            // Delete each document that matches the query
            let batch = db.batch()
            snapshot?.documents.forEach { document in
                batch.deleteDocument(favoritesCollection.document(document.documentID))
            }
            
            // Commit the batch delete
            batch.commit { error in
                if let error = error {
                    print("Error deleting favorites: \(error.localizedDescription)")
                    completion(error)
                } else {
                    print("Favorites deleted successfully.")
                    completion(nil)
                }
            }
        }
    }
    
    func deleteOrder(userID: String, orderId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let userProfileRef = db.collection("userProfile").document(userID)
        let orderRef = userProfileRef.collection("orders").document(orderId)
        
        orderRef.delete { error in
            if let error = error {
                print("Error deleting order: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Order deleted successfully!")
                completion(nil)
            }
        }
    }
    
    func toggleImageOrderFavourite(imageData: ImageData, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let orderCollection = db.collection("images")
        
        // Construct a reference to the specific document using the imageOrder's ID
        let documentReference = orderCollection.document(imageData.id ?? "")
        
        // Toggle the isFavourite property
        let updatedIsFavourite = !(imageData.isFavourite ?? false)
        
        // Update the Firestore document with the new isFavourite value
        documentReference.updateData(["isFavourite": updatedIsFavourite]) { error in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
            } else {
                // Update the local imageOrder object
                var updatedImageOrder = imageData
                updatedImageOrder.isFavourite = updatedIsFavourite
                
                // Call the completion block with the updated imageOrder
                completion(nil)
            }
        }
    }
    
    
    
    
    
    //    func addNotification(description: String, completion: @escaping (Error?) -> Void) {
    //        let db = Firestore.firestore()
    //        let notificationCollection = db.collection("notification")
    //
    //        let data: [String: Any] = ["description": description]
    //
    //        notificationCollection.addDocument(data: data) { error in
    //            if let error = error {
    //                completion(error)
    //            } else {
    //                completion(nil)
    //            }
    //        }
    //    }
    
    
    //    func fetchAllNotifications(completion: @escaping ([NotificationData]?, Error?) -> Void) {
    //        var notifications: [NotificationData] = []
    //
    //        let db = Firestore.firestore()
    //        let notificationCollection = db.collection("notification")
    //
    //        notificationCollection.getDocuments { snapshot, error in
    //            if let error = error {
    //                completion(nil, error)
    //                return
    //            }
    //
    //            if let snapshot = snapshot {
    //                for document in snapshot.documents {
    //                    let data = document.data()
    //
    //                    guard let description = data["description"] as? String else {
    //                        continue
    //                    }
    //
    //                    let id = document.documentID
    //                    let notification = NotificationData(id: id, description: description)
    //                    notifications.append(notification)
    //                }
    //
    //                completion(notifications, nil)
    //            }
    //        }
    //    }
    
    func addReviewToFirestore(description: String, rating: String, location: String, title: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let reviewsCollection = db.collection("reviews")
        
        guard let reviewerId = AppUtility.shared.userId else {return}
        
        let reviewData: [String: Any] = [
            "description": description,
            "rating": rating,
            "title": title,
            "location": location,
            "reviewerId": reviewerId,
            "username": AppUtility.shared.name ?? "",
            "date": Date()
        ]
        
        reviewsCollection.addDocument(data: reviewData) { error in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func updateReviewInFirestore(documentId: String, description: String, rating: String, location: String, title: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let reviewsCollection = db.collection("reviews")
        
        guard let reviewerId = AppUtility.shared.userId else {
            completion(NSError(domain: "YourAppDomain", code: 401, userInfo: ["message": "User ID not available"]))
            return
        }
        
        let reviewData: [String: Any] = [
            "description": description,
            "rating": rating,
            "title": title,
            "location": location,
            "reviewerId": reviewerId,
            "username": AppUtility.shared.name ?? "",
            "date": Date()
        ]
        
        // Reference the specific document by document ID
        let reviewDocument = reviewsCollection.document(documentId)
        
        // Update the document with the new data
        reviewDocument.setData(reviewData, merge: true) { error in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

    
    func deleteReviewFromFirestore(documentId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let reviewsCollection = db.collection("reviews")

        // Reference the specific document by document ID
        let reviewDocument = reviewsCollection.document(documentId)

        // Delete the document
        reviewDocument.delete { error in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

    
    func fetchReviewsByTitleAndLocation(title: String, location: String, completion: @escaping ([ReviewData]?, Error?) -> Void) {
        var reviews: [ReviewData] = []
        
        let db = Firestore.firestore()
        let reviewsCollection = db.collection("reviews")
        
        reviewsCollection
            .whereField("title", isEqualTo: title)
            .whereField("location", isEqualTo: location)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                if let snapshot = snapshot {
                    for document in snapshot.documents {
                        let data = document.data()
                        
                        guard let description = data["description"] as? String,
                              let rating = data["rating"] as? String,
                              let reviewerId = data["reviewerId"] as? String,
                              let username = data["username"] as? String else { continue }
                        
                        guard let timestamp = data["date"] as? Timestamp else {continue}

                        let id = document.documentID
                        let review = ReviewData(id: id, location: location, rating: rating, description: description, title: title, reviewerId: reviewerId, reviewId: id, username: username, date: timestamp.dateValue())
                        reviews.append(review)
                    }
                    
                    completion(reviews, nil)
                }
            }
    }
}
struct OrderData: Identifiable {
    let id: String
    let filter: String
    let location: String
    let rating: String
    let title: String
    let price: Int
    let date: String
}

struct ReviewData: Identifiable {
    let id: String
    let location: String
    let rating: String
    let description: String
    let title: String
    let reviewerId: String
    let reviewId: String
    let username: String
    let date: Date
}


struct NotificationData: Identifiable {
    let id: String = UUID().uuidString
    let description: String
}

struct FavoriteData {
    let documentID: String
    let favoriteImageID: String
    
}
