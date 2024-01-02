//
//  UserProfileScreen.swift
//  StyleEase
//
//  Created by Sam 77 on 2023-12-26.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore


struct UserProfileScreen: View {
    @State private var editProfile = false
    @State private var imageURL = ""
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var order = ""
    @State private var address = ""
    @State private var balance = 0
    @State private var image = UIImage()
    
    var body: some View {
        
//        NavigationLink(destination: EditUserProfile(firstname: $firstname, lastname: $lastname, address: $address, order: $order, imageURL: $imageURL), isActive: $editProfile) {
//            EmptyView()
//        }
//        .isDetailLink(false)
        
        
        ScrollView {
            VStack {
                profileImage
                
                Text(firstname)
                    .font(.title)
//                    .foregroundColor(.brandColor)
                    .padding(.top, 10)
                
                Text(firstname)
                    .font(.title)
//                    .foregroundColor(.brandColor)
                    .padding(.top, 10)
                
                Text(AppUtility.shared.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                
                Divider().padding(20)
                
                userInformation
                
                Spacer()
            }
            .toolbar(.visible, for: .navigationBar)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        editProfile.toggle()
                    }
                }
            }
            .onAppear {
                loadUserProfile()
            }
        }
    }
    
    private var profileImage: some View {
        AsyncImage(url: URL(string: imageURL)) { phase in
            switch phase {
            case .empty:
                Image(systemName: "person.crop.circle.fill.badge.xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .padding(.top, 20)
                
            case .success(let image):
                image
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 120, height: 120)
                    .padding(.top, 20)
                
            case .failure:
                Image(systemName: "person.crop.circle.fill.badge.xmark")
                    .frame(width: 120, height: 120)
                    .padding(.top, 20)
                
            @unknown default:
                Image(systemName: "person.crop.circle.fill.badge.xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 20)
            }
        }
    }
    
    
    private var userInformation: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "User Information")
            
            
            UserInfoRow(title: "Address", value: "\(AppUtility.shared.city ?? "")")
            UserInfoRow(title: "Wallet Balance", value: "$\(balance)")
            UserInfoRow(title: "Your Order", value: "\(order)")

            
            Divider()
                    
//            Text(bio)
//                .font(.body)
//                .foregroundColor(.black)
        }
        .padding(.horizontal, 20)
    }
    
    private func loadUserProfile() {
        FirebaseManager.shared.getUserProfile(withId: AppUtility.shared.userId!) { data in
            firstname = data?.firstName ?? ""
            lastname = data?.lastName ?? ""
            address = data?.address ?? ""
            order = data?.order ?? ""
            imageURL = data?.profileImageURL ?? ""
            balance = data?.balance ?? 0
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title)
//            .foregroundColor(.brandColor)
            .padding(.bottom, 10)
    }
}

struct UserInfoRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.blue)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.black)
        }
        .padding(.vertical, 5)
    }
}
