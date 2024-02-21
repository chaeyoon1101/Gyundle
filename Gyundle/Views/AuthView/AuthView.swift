import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text("견들")
                .font(.largeTitle)
                .bold()
                .padding(.top, 48)
            
            Spacer()
            
            appleLoginButton
                .overlay {
                    SignInWithAppleButton { request in
                        authViewModel.send(action: .appleLogin(request))
                    } onCompletion: { result in
                        authViewModel.send(action: .appleLoginCompletion(result))
                    }
                    .blendMode(.color)
                }
            
            
            kakaoLoginButton
                .onTapGesture {
                    authViewModel.send(action: .kakaoLogin)
                    print("tapped Kakao login")
                }
            
            Button("Log out") {
                authViewModel.send(action: .signOut)
            }
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
    
    var appleLoginButton: some View = {
        return HStack {
            Image(systemName: "apple.logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            Text("Apple로 시작하기")
        }
        .font(.headline)
        .foregroundStyle(Color.bg)
        .frame(width: 280, height: 46)
        .background(Color.fg)
        .cornerRadius(12)
    }()
    
    var kakaoLoginButton: some View = {
        return HStack {
            Image("KakaoLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            Text("카카오로 시작하기")
                .font(.headline)
        }
        .foregroundStyle(.black)
        .frame(width: 280, height: 46)
        .background(Color.kakaoBackground)
        .cornerRadius(12)
    }()
}

#Preview {
    AuthView()
}
