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
            Image("kakao_login_medium_narrow")
                .frame(width: 280, height: 50)
            Button("Login Button") {
                authViewModel.registerUser(email: "test@gmail.com", password: "testacc1234!!")
            }
            
            Button("Log out") {
                try? Auth.auth().signOut()
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
