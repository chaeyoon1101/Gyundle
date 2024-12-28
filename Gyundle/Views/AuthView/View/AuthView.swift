import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct AuthView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text("견들")
                .font(.largeTitle)
                .bold()
                .padding(.top, 48)
            
            Spacer()
            
            AppleLoginButton()
            
            KakaoLoginButton()
            
            Button("로그아웃 테스트") {
                Task {
                    await authViewModel.send(action: .signOut)
                }
            }
        }
        .font(.headline)
    }
    
    @ViewBuilder
    func AppleLoginButton() -> some View {
        HStack {
            Image(systemName: "apple.logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            Text("Apple로 시작하기")
        }
        .frame(width: 280, height: 46)
        .foregroundStyle(colorScheme == .dark ? .black : .white)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(colorScheme == .dark ? .white : .black)
        }
        .overlay {
            SignInWithAppleButton { request in
                Task {
                    await authViewModel.send(action: .appleRequest(request))
                }
            } onCompletion: { result in
                Task {
                    await authViewModel.send(action: .appleLoginCompletion(result))
                }
            }
            .blendMode(.color)
        }
    }
    
    @ViewBuilder
    func KakaoLoginButton() -> some View {
        HStack {
            Image("KakaoLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            Text("카카오로 시작하기")
                .font(.headline)
        }
        .frame(width: 280, height: 46)
        .foregroundStyle(.black)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(ColorConstant.kakao)
        }
        .onTapGesture {
            Task {
                await authViewModel.send(action: .kakaoLogin)
                print("tapped Kakao login")
            }
        }
    }
}

#Preview {
    AuthView()
}
