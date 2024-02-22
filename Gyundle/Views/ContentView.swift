import SwiftUI
import FirebaseAuth
import Firebase

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var selection: Tab = .homeView
    
    enum Tab {
        case homeView
        case friendView
        case searchView
        case myView
    }
    
    var body: some View {
        Group {
            switch authViewModel.status {
            case .loggedIn:
                mainView
            case .loggedOut:
                AuthView()
            case .signUp:
                SignUpView()
            }
        }
        .onChange(of: authViewModel.status) { newStatus in
            if newStatus == .loggedIn, let currentUser = authViewModel.currentUser {
                userViewModel.fetchUserData(id: currentUser.uid)
            }
        }
        .onAppear {
            authViewModel.checkStatus()
        }
    }
    
    var mainView: some View {
        TabView(selection: $selection) {
            MainView()
                .tabItem {
                    Image(systemName: "house")
                    Text("홈")
                }.tag(Tab.homeView)
            AuthView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("친구")
                }.tag(Tab.friendView)
            SignUpView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("검색")
                }.tag(Tab.searchView)
            MyPageView()
                .tabItem {
                    Image(systemName: "person")
                    Text("마이페이지")
                }.tag(Tab.myView)
        }.foregroundStyle(.fg)
    }
        
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(UserViewModel())
}
