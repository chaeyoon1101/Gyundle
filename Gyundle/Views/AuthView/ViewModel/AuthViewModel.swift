import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import Firebase

enum AuthAction {
    case appleLogin(ASAuthorizationAppleIDRequest)
    case appleLoginCompletion(Result<ASAuthorization, Error>)
    case kakaoLogin
    case signOut
}

enum AuthStatus {
    case loggedIn
    case loggedOut
    case signUp
}

class AuthViewModel: NSObject, ObservableObject {
    @Published var status: AuthStatus = .loggedOut
    @Published var currentUser: FirebaseAuth.User?
    
    override init() {
        super.init()
        self.addStateDidChangeListener()
    }
    
    
    // MARK: 현재 유저 Auth 상태 확인
    func checkStatus() {
        guard let currentUser = Auth.auth().currentUser else {
            status = .loggedOut
            print("현재 로그아웃 상태")
            return
        }
        
        self.status = .loggedIn
        
        // db에 유저 데이터가 있는 지 확인 후 없으면 회원가입 상태로 변경
        FirebaseManager.shared.hasUserInfo(id: currentUser.uid) { hasUserInfo in
            if !hasUserInfo {
                self.status = .signUp
            }
        }
        
        print("유저 auth 상태: \(self.status)")
    }
    
    
    // MARK: 유저 Auth 변경 감시
    private func addStateDidChangeListener() {
        Auth.auth().addStateDidChangeListener() { auth, user in
            self.checkStatus()
        }
    }
    
    func send(action: AuthAction) {
        switch action {
        case .appleLogin(let request):
            handleAppleLogin(request)
            
        case .appleLoginCompletion(let result):
            handleAppleLoginCompletion(result)
            
        case .kakaoLogin:
            handleKakaoLogin()
        
        case .signOut:
            signOut()
        }
    }
    
    // MARK: Apple Login
    private func handleAppleLogin(_ request: ASAuthorizationAppleIDRequest) {
        AppleAuthManager.shared.login(request)
    }
    
    private func handleAppleLoginCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let user):
            guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                print("error with firebase")
                return
            }
            
            AppleAuthManager.shared.authenticate(credential: credential) { error in
                if let error = error {
                    print("애플 로그인 실패: ", error)
                } else {
                    self.checkStatus()
                }
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    // MARK: Kakao Login
    private func handleKakaoLogin() {
        print("kakao login")
        KakaoAuthManager.shared.login { error in
            if let error = error {
                print("Kakao login error:", error)
                return
            }
            
            self.checkStatus()
        }
    }

        
    // MARK: 로그아웃
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
}
