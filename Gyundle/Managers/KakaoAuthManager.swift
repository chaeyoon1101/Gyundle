import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import FirebaseAuth

class KakaoAuthManager {
    static let shared = KakaoAuthManager()
    
    private init() { }
    
    func login(completion: @escaping (Error?) -> Void) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                } else {
                    print("loginWithKakaoTalk() success.")

                    _ = oauthToken
                    
                    self.signInFirebase() { error in
                        if let error = error {
                            completion(error)
                            return
                        }
                        
                        completion(nil)
                    }
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                } else {
                    print("loginWithKakaoAccount() success.")

                    _ = oauthToken
                    
                    self.signInFirebase() { error in
                        if let error = error {
                            completion(error)
                            return
                        }
                        
                        completion(nil)
                    }
                }
            }
        }
    }
    
    private func signInFirebase(completion: @escaping (Error?) -> Void) {
        UserApi.shared.me() { user, error in
            if let error = error {
                print("카카오톡 사용자 정보가져오기 에러 \(error.localizedDescription)")
                // completion
                return
            }
            
            guard let email = user?.kakaoAccount?.email,
                  let password = user?.id else {
                print("email나 password중 nil")
                // completion
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
           }
        }
    }
}
