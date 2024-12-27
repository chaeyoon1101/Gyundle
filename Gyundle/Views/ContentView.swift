import SwiftUI
import FirebaseAuth
import Firebase

enum Tab {
    case homeView
    case friendView
    case searchView
    case myView
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var selection: Tab = .homeView
    
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
        }
    }
    
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
        }
        .accentColor(ColorConstant.fgPrimary)
    }
        
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
