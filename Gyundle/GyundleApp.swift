import SwiftUI
import Firebase
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct GyundleApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var userViewModel = UserViewModel()
    @StateObject var memoryViewModel = MemoryViewModel()
    
    let kakaoAppKey = Bundle.main.appKey(for: "KakaoNativeAppKey")
    
    init() {
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(userViewModel)
                .environmentObject(memoryViewModel)
                .onOpenURL(perform: { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}
