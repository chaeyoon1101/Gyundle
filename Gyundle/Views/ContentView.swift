//
//  ContentView.swift
//  Gyundle
//
//  Created by 임채윤 on 2/4/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selection: Tab = .homeView
    
    enum Tab {
        case homeView
        case friendView
        case searchView
        case myView
    }
    
    var body: some View {
        Group {
            if authViewModel.loggedIn {
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
                        }.tag(Tab.homeView)
                    Text("searchView")
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("검색")
                        }.tag(Tab.homeView)
                    Text("myView")
                        .tabItem {
                            Image(systemName: "person")
                            Text("마이페이지")
                        }.tag(Tab.homeView)
                }
            } else {
                AuthView()
            }
        }
        .onAppear {
            authViewModel.checkLoginStatus()
        }
        
    }
        
}

#Preview {
    ContentView()
}
