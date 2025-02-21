import SwiftUI
import FirebaseAuth
import Firebase

enum TabItem: String, CaseIterable {
    case friend
    case explore
    case home
    case timeCapsule
    case myPage
    
    var symbolImage: String {
        switch self {
        case .friend: "person.2"
        case .explore: "safari"
        case .home: "house"
        case .timeCapsule: "clock.arrow.trianglehead.counterclockwise.rotate.90"
        case .myPage: "person"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // MARK: ViewModels
    @StateObject private var dailyMemoryViewModel = DailyMemoryViewModel()
    @StateObject private var dogWalkingMemoryViewModel = DogWalkingMemoryViewModel()
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    // MARK: TabBar
    @State private var selection: TabItem = .home
    @State private var showMemorizeView: Bool = false
    
    var body: some View {
        ZStack {
            Self.background(color: ColorConstant.bgPrimary)
            
            switch authViewModel.status {
            case .initializing:
                LoadingView()
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
    func MainView() -> some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                Group {
                    SignUpView()
                        .tag(TabItem.friend)
                    AuthView()
                        .tag(TabItem.explore)
                    HomeView(showMemorizeView: $showMemorizeView)
                        .tag(TabItem.home)
                    Text("Time Capsule")
                        .tag(TabItem.timeCapsule)
                    MyPageView()
                        .tag(TabItem.myPage)
                }
                .safeAreaPadding(.bottom, 50)
                .toolbar(.hidden, for: .tabBar)
            }
            
            TabBar()
        }
        .accentColor(ColorConstant.fgPrimary)
    }
    
    @ViewBuilder
    private func TabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.rawValue) { tab in
                TabButton(tab)
            }
        }
        .frame(height: 45)
        .padding(.horizontal, 15)
        .padding(.bottom, 5)
        .background(.background.shadow(.drop(color: .primary.opacity(0.12), radius: 5)))
    }
    
    @ViewBuilder
    private func TabButton(_ tab: TabItem) -> some View {
        let isActive = tab == selection
        let isHome = tab == .home
        
        if isHome {
            VStack {
                Image(systemName: isActive ? "plus" : tab.symbolImage)
                    .symbolVariant(.fill)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(isActive ? .primary : .tertiary)
                    .background {
                        Circle()
                            .fill(ColorConstant.bgContent)
                            .frame(width: 50, height: 50)
                            .shadow(color: .primary.opacity(0.2), radius: 5)
                    }
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
            .onTapGesture {
                if isActive {
                    showMemorizeView = true
                } else {
                    selection = tab
                }
            }
        } else {
            VStack {
                Image(systemName: tab.symbolImage)
                    .symbolVariant(.fill)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(isActive ? .primary : .tertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
            .onTapGesture {
                selection = tab
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
