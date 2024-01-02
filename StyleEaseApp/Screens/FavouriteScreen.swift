//
//  FavouriteScreen.swift
//  StyleEase
//
//  Created by Sam 77 on 2023-12-26.
//

import Foundation
import SwiftUI

struct FavoriteScreen: View {
//    @Binding var presentSideMenu: Bool
    
    //TODO: - Update follwoing two data declaration
    @State private var imageData = [ImageData]()
    @State private var selectedImageData: ImageData?
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack{
                    Button{
//                        presentSideMenu.toggle()
                    } label: {
                        Image("menu")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .padding(16)
                    }
                    Spacer()
                }
                
                Text("Your Favourites")
                
                List {
                    //TODO: - Update list with image Data collections
//
                    ForEach(imageData, id: \.id) { item in
                        
                        NavigationLink {
                            //TODO: - Updat Detals Screen
//                            DetailsScreen(imageData: item)
                            DetailScreen()
                        } label: {
                            FavoriteListingCellView(place: item)
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(PlainListStyle())
                
                Spacer()
            }
            .onAppear {
                FirebaseManager.shared.fetchFavouriteList { imagesData, error in
                    self.imageData = imagesData ?? []
                }
            }
        }
    }
    
    private func delete(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        FirebaseManager.shared.deleteFavoriteByImageID(userID: AppUtility.shared.userId!, favoriteImageID: imageData[index].id) { err in
            if err == nil {
                print("Successfully Removed from List")
            }
        }
        imageData.remove(at: index)
    }
}

struct FavoriteListingCellView: View {
    
    var place = ImageData(id: "", imageURL: "", title: "", location: "", rating: "", filter: "", isFavourite: false, description: "", latitude: 0.00, longitude: 0.00, price: 0)
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: place.imageURL)) { phase in
                switch phase {
                case .empty:
                    // Placeholder image or view
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 150)
                case .failure:
                    // Placeholder image or view
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                @unknown default:
                    fatalError()
                }
            }
            .frame(width: 180, height: 150) // Set the frame size for the wrapper view
            .cornerRadius(8) // Apply corner radius to the wrapper view
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 2)) // Optional: Add a border
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text(place.title)
                    .font(.headline)
                Text(place.location)
                    .font(.subheadline)
            }
            
            
            Spacer()
        }
        .cornerRadius(8)
    }
}
