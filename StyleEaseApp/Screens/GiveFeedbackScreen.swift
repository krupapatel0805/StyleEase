//
//  GiveFeedbackScreen.swift
//  StyleEaseApp
//
//  Created by Sam 77 on 2023-12-28.
//

import SwiftUI
import StarRating


struct GiveFeedbackScreen: View {
    
    @State private var reviewText = ""
    @State private var isReviewSubmitted = false
    @State var customConfig = StarRatingConfiguration(numberOfStars: 5, minRating: 1)
    @State var rating: Double = 0.5
    @Binding var imageData: ImageData
    @State private var showAlert = false
    @State var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    var isEditReview = false
    var reviewData = ReviewData(id: "", location: "", rating: "", description: "", title: "", reviewerId: "", reviewId: "", username: "", date: Date())
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    let title = isEditReview ? "Edit your review" : "Write your review"
                    Text(title)
                        .font(.title3)
                        .padding()
                    
                    TextEditor(text: $reviewText)
                        .frame(maxHeight: 100)
                        .padding()
                        .border(Color.gray, width: 1)
                        .cornerRadius(5)
                        

                    // set the initialRating
                    // add a callback to do something with the new rating
                    StarRating(initialRating: rating, onRatingChanged: {
                        print($0)
                            rating = $0 // Update the @Binding variable with the new rating

                    }).frame(width: 300, height: 100)
                        .onAppear {
                            rating = Double(reviewData.rating) ?? 0.0
                        }

                    
                    Button(action: {
                        // Submit the review (you can customize this part)
                        self.submitReview()
                    }) {
                        Text("Submit Review")
                            .font(.title3)
                            .padding()
                            .background(Color(red: 0.39, green: 0.56, blue: 0.89))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                }
                .padding()
                .onAppear {
                    if isEditReview {
                        reviewText = reviewData.description
                        
                    }
                }
                .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Message"),
                                message: Text("\(alertMessage)"),
                                dismissButton: .default(Text("OK"))
                            )
            }
            }
        }
    }

    func submitReview() {
        // Perform the review submission logic here
        // For demonstration purposes, we'll just set a flag to indicate submission
        if isEditReview {
            editReview()
        } else {
            addNewReview()
        }
        
    }
    
    func editReview() {
        
        if validate() {
            FirebaseManager.shared.updateReviewInFirestore(documentId: reviewData.reviewId,
                                                           description: reviewText,
                                                           rating: String(rating),
                                                           location: imageData.location,
                                                           title: imageData.title) { err in
                if err == nil {
                    reviewText = ""
                    alertMessage = "Review Updated Successfully"
                    showAlert = true
                }
            }
        } else {
            alertMessage = "Please Enter Review"
            showAlert = true
        }
    }
    
    func addNewReview() {
        isReviewSubmitted = true
        if validate() {
            FirebaseManager.shared.addReviewToFirestore(description: reviewText, rating: String(rating), location: imageData.location, title: imageData.title) { error in
                if error == nil {
                    print("Review Submitted")
                    reviewText = ""
                    alertMessage = "Review Submitted"
                    showAlert = true
                } else {
                    print("Error")
                    alertMessage = "Error"
                    showAlert = true
                }
            }
        } else {
            alertMessage = "Please Enter Review"
            showAlert = true
        }
    }
    
    func validate() -> Bool {
        if reviewText.isEmpty {
            return false
        } else {
            return true
        }
    }
}
