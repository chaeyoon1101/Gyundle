import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import FirebaseAuth

@MainActor
class KakaoAuthManager {
    static let shared = KakaoAuthManager()
    
    private init() { }
    
    func login() async throws {
        if UserApi.isKakaoTalkLoginAvailable() {
            try await loginWithKakaoTalk()
        } else {
            try await loginWithKakaoAccount()
        }
    }
    
    private func loginWithKakaoTalk() async throws {
        let _: OAuthToken = try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk { OAuthToken, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let token = OAuthToken {
                    continuation.resume(returning: token)
                }
            }
        }
        
        try await signInFirebase()
    }
    
    private func loginWithKakaoAccount() async throws {
        let _: OAuthToken = try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount { OAuthToken, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let token = OAuthToken {
                    continuation.resume(returning: token)
                }
            }
        }
        
        try await signInFirebase()
    }
    
    private func signInFirebase() async throws {
        let kakaoUser: KakaoSDKUser.User = try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.me { user, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let user {
                    continuation.resume(returning: user)
                }
            }
        }
        
        guard let email = kakaoUser.kakaoAccount?.email,
              let password = kakaoUser.id else {
            throw AuthError.kakaoLoginFailed
        }
        
        
        do {
            try await FirebaseManager.shared.createUser(withEmail: email, password: String(password))
        } catch {
            try await FirebaseManager.shared.signIn(withEmail: email, password: String(password))
        }
    }
}
