import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            SignInWithAppleButton { request in
                authViewModel.send(action: .appleLogin(request))
            } onCompletion: { result in
                authViewModel.send(action: .appleLoginCompletion(result))
            }
            .frame(width: 280, height: 50)
            
            Image("kakao_login_medium_wide")
                .frame(width: 280, height: 50)
                .onTapGesture {
                    authViewModel.send(action: .kakaoLogin)
                    print("tapped Kakao login")
                }
        
            
            Button("Log out") {
                authViewModel.send(action: .signOut)
                print(Auth.auth().currentUser?.email)
            }
            .background(.foreground)
            .frame(width: 280, height: 60)
            
            .onAppear {
                if let user = Auth.auth().currentUser {
                    let uid = user.uid
                    let email = user.email
                    let displayName = user.displayName
                    
                    print(uid, email, displayName)
                }
            }
        }
    }
}

#Preview {
    AuthView()
}
