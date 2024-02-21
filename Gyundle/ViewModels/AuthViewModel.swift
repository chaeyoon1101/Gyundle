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
    @Published var userViewModel: UserViewModel
    
    @Published var status: AuthStatus = .loggedOut
    
    @Published var currentUser: FirebaseAuth.User?
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        super.init()
        self.addStateDidChangeListener()
    }
    
    func checkStatus() {
        currentUser = Auth.auth().currentUser
        
        if currentUser != nil {
            status = .loggedIn
            userViewModel.hasUserInfo(id: currentUser!.uid) { hasUserInfo in
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
    
    func uploadUserInfo(userData: SignUpData) {
        let db = Firestore.firestore()
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
        
        let collectionRef = db.collection("users")
        do {
            try collectionRef.document(currentUser.uid).setData(from: user) { error in
                if let error = error {
                    print("User Info 업로드 실패", error.localizedDescription)
                } else {
                    self.checkStatus()
                    print("업로드 성공")
                }
            }
        } catch let error {
            print("\(error)")
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
            
            self.checkStatus()
            
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
                    let isNewUser = result?.additionalUserInfo == nil
                
                    if isNewUser {
                        Auth.auth().createUser(withEmail: email, password: String(password)) { result, error in
                            if let error = error {
                                print("파이어베이스 사용자 생성 실패: \(error.localizedDescription)")
                            } else {
                                print("파이어베이스 사용자 생성 성공")
                            }
                        }
                    } else {
                        if let error = error {
                           print("파이어베이스 로그인 실패: \(error.localizedDescription)")
                        } else {
                           print("파이어베이스 로그인 성공")
                        }
                    }
                    self.checkStatus()
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
