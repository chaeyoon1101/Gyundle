import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import FirebaseAuth
import AuthenticationServices
import CryptoKit


enum AuthAction {
    case appleLogin(ASAuthorizationAppleIDRequest)
    case appleLoginCompletion(Result<ASAuthorization, Error>)
    case kakaoLogin
    case signOut
}

class AuthViewModel: NSObject, ObservableObject {
    @Published var loggedIn: Bool = false
    
    override init() {
        super.init()
        addStateDidChangeListener()
    }
    
    func checkLoginStatus() {
        if Auth.auth().currentUser != nil {
            loggedIn = true
        } else {
            loggedIn = false
        }
        
        print("checkLoginStatus")
    }
    
    private func addStateDidChangeListener() {
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.loggedIn = true
                print("Auth state changed, is signed in")
            } else {
                self.loggedIn = false
                print("Auth state changed, is signed out")
            }
        }
    }
    
    var currentUser: FirebaseAuth.User? = {
        let user = Auth.auth().currentUser
        
        return user
    }()
    
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
        nonce = randomNonceString()
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nonce)
    }
    
    private func handleAppleLoginCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let user):
            print("success")
            guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                print("error with firebase")
                return
            }
            
//                print("email", credential.email)
//                print("fullname", credential.fullName)
            print(currentUser?.uid)
            
            authenticate(credential: credential)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    private var nonce = ""
    
    private func authenticate(credential: ASAuthorizationAppleIDCredential) {
        //getting token
        guard let token = credential.identityToken else {
            print("error with firebase")
            return
        }
        
        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("error with token")
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        Auth.auth().signIn(with: firebaseCredential) { result, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            print("로그인 완료")
        }
    }
    
    // Kakao Login
    
    private func handleKakaoLogin() {
        print("kakao login")
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                } else {
                    print("loginWithKakaoTalk() success.")

                    _ = oauthToken
                    
                    self.signInFirebase()
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                    if let error = error {
                        print(error)
                    } else {
                        print("loginWithKakaoAccount() success.")

                        _ = oauthToken
                        
                        self.signInFirebase()
                    }
                }
        }
    }
    
    private func signInFirebase() {
        UserApi.shared.me() { user, error in
            if let error = error {
                print("카카오톡 사용자 정보가져오기 에러 \(error.localizedDescription)")
            } else {
                guard let email = user?.kakaoAccount?.email,
                      let password = user?.id else {
                    print("email나 password중 nil")
                    return
                }
                
                Auth.auth().signIn(withEmail: email, password: String(password)) { result, error in
                   if let error = error {
                       print("파이어베이스 로그인 실패: \(error.localizedDescription)")
                       
                       Auth.auth().createUser(withEmail: email, password: String(password)) { result, error in
                           if let error = error {
                               print("파이어베이스 사용자 생성 실패: \(error.localizedDescription)")
                           } else {
                               print("파이어베이스 사용자 생성 성공")
                               print(result?.user.email)
                           }
                       }
                   } else {
                       print("파이어베이스 로그인 성공")
                   }
               }
            }
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


private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    
    return hashString
}

private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError(
                    "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                )
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}
