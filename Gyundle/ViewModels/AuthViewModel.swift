import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

enum AuthAction {
    case appleLogin(ASAuthorizationAppleIDRequest)
    case appleLoginCompletion(Result<ASAuthorization, Error>)
    case emailSignUp(String, String)
}

class AuthViewModel: NSObject, ObservableObject {
    @Published var loggedIn: Bool = false
    
    override init() {
        super.init()
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
    
    func send(action: AuthAction) {
        switch action {
        case .appleLogin(let request):
            nonce = randomNonceString()
            request.requestedScopes = [.email, .fullName]
            request.nonce = sha256(nonce)
            
        case .appleLoginCompletion(let result):
            switch result {
            case .success(let user):
                print("success")
                guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                    print("error with firebase")
                    return
                }
                
                print("email", credential.email)
                print("fullname", credential.fullName)
                
                authenticate(credential: credential)
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        case .emailSignUp(let email, let password):
            registerUser(email: email, password: password)
        }
    }
    
    
    
    // Apple Login
    var nonce = ""
    
    func authenticate(credential: ASAuthorizationAppleIDCredential) {
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
    
    // Email Login
    func registerUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error : \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else { return }
            
            print(user.uid)
        }
    }
}


func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    
    return hashString
}

func randomNonceString(length: Int = 32) -> String {
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
