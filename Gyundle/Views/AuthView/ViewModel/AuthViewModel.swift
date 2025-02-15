import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import Firebase

enum AuthAction {
    case appleRequest(ASAuthorizationAppleIDRequest)
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
        authStateListenerHandle = Auth.auth().addStateDidChangeListener() { [weak self] _, user in
            guard let self else { return }
            
            if let user {
                Task {
                    do {
                        try await UserManager.shared.fetchUserData(id: user.uid)
                            
                        await MainActor.run {
                            self.status = .loggedIn
                        }
                    } catch {
                        print("User Data가 존재하지 않음:", error.localizedDescription)
                        await MainActor.run {
                            self.status = .signUp
                        }
                    }
                }
            } else {
                self.status = .loggedOut
            }
            
            print("유저 auth 상태: \(self.status)")
        }
    }
    
    @MainActor
    func send(action: AuthAction) async {
        switch action {
        case .appleRequest(let request):
            handleAppleRequest(request)
            
        case .appleLoginCompletion(let result):
            await handleAppleLoginCompletion(result)
            
        case .kakaoLogin:
            await handleKakaoLogin()
        
        case .signOut:
            signOut()
        }
    }
    
    // MARK: Apple Login
    @MainActor
    private func handleAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        AppleAuthManager.shared.login(request)
    }
    
    @MainActor
    private func handleAppleLoginCompletion(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let user):
            guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                print("error with firebase")
                return
            }
            
            do {
                try await AppleAuthManager.shared.authenticate(credential: credential)
            } catch {
                print("Apple Login 실패:", error)
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    // MARK: Kakao Login
    @MainActor
    private func handleKakaoLogin() async {
        print("kakao login")
        
        do {
            try await KakaoAuthManager.shared.login()
        } catch {
            print("카카로 로그인 실패:", error.localizedDescription)
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
