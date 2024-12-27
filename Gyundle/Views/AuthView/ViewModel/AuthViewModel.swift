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
    case initializing
    case loggedIn
    case loggedOut
    case signUp
}

class AuthViewModel: ObservableObject {
    @Published var status: AuthStatus = .initializing
    @Published var currentUser: FirebaseAuth.User?
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    // MARK: 유저 Auth 상태 확인
    private func setupAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener() { [weak self] auth, user in
            guard let self else { return }
            
            if let user {
                Task {
                    let hasUserInfo = await FirebaseManager.shared.hasUserInfo(id: user.uid)
                    await MainActor.run {
                        self.status = hasUserInfo ? .loggedIn : .signUp
                    }
                }
            } else {
                self.status = .loggedOut
            }
            
            print("유저 auth 상태: \(self.status)")
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
            
            Task {
                AppleAuthManager.shared.authenticate(credential: credential) { error in
                    if let error = error {
                        print("애플 로그인 실패: ", error)
                        return
                    }
                }
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    // MARK: Kakao Login
    private func handleKakaoLogin() {
        print("kakao login")
        
        Task {
            KakaoAuthManager.shared.login { error in
                if let error = error {
                    print("Kakao login error:", error)
                    return
                }
                
            }
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
    
    deinit {
        if let authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(authStateListenerHandle)
        }
    }
}
