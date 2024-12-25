import SwiftUI
import Firebase
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct GyundleApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var userViewModel = UserViewModel()
    
    init() {
        FirebaseApp.configure()
        
        let kakaoAppKey = Bundle.main.appKey(for: "KakaoNativeAppKey")
        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(userViewModel)
                .onOpenURL(perform: { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}
