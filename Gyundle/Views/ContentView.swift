import SwiftUI
import FirebaseAuth
import Firebase

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    
    // MARK: ViewModels
    @StateObject private var dailyMemoryViewModel = DailyMemoryViewModel()
    @StateObject private var dogWalkingMemoryViewModel = DogWalkingMemoryViewModel()
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    // MARK: TabBar
    @State private var selection: Tab = .homeView
    enum Tab {
        case homeView
        case friendView
        case searchView
        case myView
    }
    
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
        }
        .environmentObject(calendarViewModel)
        .environmentObject(dailyMemoryViewModel)
        .environmentObject(dogWalkingMemoryViewModel)
    }
    
    @ViewBuilder
    func LoadingIndicator() -> some View {
        LoadingView()
    }
    
    @ViewBuilder
    func MainView() -> some View {
        NavigationStack {
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
        }
        .accentColor(ColorConstant.fgPrimary)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
