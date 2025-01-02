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
    
    @StateObject private var detailImageViewModel = DetailImageViewModel()
    @State private var selection: Tab = .homeView
    
    
    var body: some View {
        ZStack {
            Self.background(color: ColorConstant.bgPrimary)
            
            switch authViewModel.status {
            case .initializing:
                LoadingIndicator()
            case .loggedIn:
                MainView()
            case .loggedOut:
                AuthView()
            case .signUp:
                SignUpView()
            }
            
            if detailImageViewModel.isPresented {
                ImageDetailView()
            }
        }
        .environmentObject(detailImageViewModel)
    }
    
    @ViewBuilder
    func LoadingIndicator() -> some View {
        LoadingView()
    }
    
    @ViewBuilder
    func MainView() -> some View {
        TabView(selection: $selection) {
            HomeView()
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
