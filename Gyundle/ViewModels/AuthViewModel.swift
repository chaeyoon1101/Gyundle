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
    
    func checkStatus() {
        currentUser = Auth.auth().currentUser
        
        if currentUser != nil {
            status = .loggedIn
            FirebaseManager.shared.hasUserInfo(id: currentUser!.uid) { hasUserInfo in
                self.status = hasUserInfo ? .loggedIn : .signUp
            }
        } else {
            status = .loggedOut
        }
        
        print("auth status: ", status)
    }
    
    private func addStateDidChangeListener() {
        Auth.auth().addStateDidChangeListener() { auth, user in
            self.checkStatus()
        }
    }
    
    func uploadUserInfo(userData: UserInfoData) {
        guard let currentUser = currentUser else {
            print("can't upload user info currnetUser is nil")
            return
        }
        
        let user = User(
            id: currentUser.uid,
            email: currentUser.email ?? currentUser.uid,
            name: userData.name,
            photo: userData.photo,
            dateOfBirth: userData.dateOfBirth
        )
        
        FirebaseManager.shared.uploadUserInfo(user: user) { error in
            if let error = error {
                print("error")
            }
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
            print("case kakao login")
            handleKakaoLogin()
        
        case .signOut:
            signOut()
        }
    }
    
    // Apple Login
    private func handleAppleLogin(_ request: ASAuthorizationAppleIDRequest) {
        AppleAuthManager.shared.login(request)
    }
    
    private func handleAppleLoginCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let user):
            print("success")
            guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                print("error with firebase")
                return
            }
            
            AppleAuthManager.shared.authenticate(credential: credential) { error in
                if let error = error {
                    // 에러처리
                } else {
                    self.checkStatus()
                }
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    // Kakao Login
    
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

    
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
}
