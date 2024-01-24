//
//  SplashScreen.swift
//  StyleEaseApp
//


import SwiftUI

struct SplashScreen: View {
    @State var isActive: Bool = false
    var body: some View {
        if isActive {
            LoginScreen()
        } else {
            ZStack {
                Image("splash")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Text("StyleEase")
                        .foregroundStyle(.white)
                        .font(.system(size: 50))
                        .bold()
                    
                    Text("create your own style…")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .bold()
                        
                }
                .frame(maxWidth: UIScreen.main.bounds.width - 20)
                .frame(height: 180)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
