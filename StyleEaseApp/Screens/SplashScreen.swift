//
//  SplashScreen.swift
//  StyleEase
//
//  Created by Sam 77 on 2023-12-21.
//

import Foundation
import SwiftUI

struct SplashScreen: View {
    @Binding var isShowing: Bool

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.88, blue: 0.82)
            .ignoresSafeArea()

            VStack {
                Image("Logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                .background(Color(red: 0.93, green: 0.88, blue: 0.82))
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                    
                Text("StyleEase")
                  .font(Font.custom("Acme", size: 52))
                  .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                
                Text("create your own style…")
                  .font(
                    Font.custom("Roboto", size: 20)
                      .weight(.medium)
                  )
                  .foregroundColor(Color(red: 0.57, green: 0.44, blue: 0.2))
                  .frame(width: 249, height: 14, alignment: .topLeading)
            }
        }
        .onTapGesture {
            withAnimation {
                isShowing = false
            }
        }
    }
}
