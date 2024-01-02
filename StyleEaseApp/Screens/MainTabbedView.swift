import SwiftUI

struct MainTabbedView: View {
    
//    @State var presentSideMenu = false
    @State var selectedSideMenuTab = 0
    @State private var isLoggedIn = true
    @ObservedObject var authViewModel: AuthViewModel
    
    
    var body: some View {
        NavigationStack{
            VStack {
                ZStack{
                    TabView(selection: $selectedSideMenuTab) {
                        LogoutView(authViewModel: authViewModel)
                            .onAppear {
                                authViewModel.signOut()
                            }
                            .tag(4)
                       
                    }
//                    SideMenu(isShowing: $presentSideMenu, content: AnyView(SideMenuView(selectedSideMenuTab: $selectedSideMenuTab, presentSideMenu: $presentSideMenu)))
                    
                }
            }
        }
    }
}

struct LogoutView: View {
    @ObservedObject var authViewModel: AuthViewModel
    var body: some View {
        Text("Logging out")
    }
}
