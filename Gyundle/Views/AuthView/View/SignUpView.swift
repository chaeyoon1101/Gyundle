import SwiftUI

enum SignUpViewPage {
    case nameView
    case birthdayView
    case profileView
}

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var signUpViewModel = SignUpViewModel()
    
    var body: some View {
        GeometryReader { let size = $0.size
            
            ScrollViewReader { scrollViewProxy in
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    // MARK: 양 옆으로 넘어가는 뷰들
                    HStack(spacing: 0) {
                        SignUpNameView()
                            .id(SignUpViewPage.nameView)
                            .frame(width: size.width, height: size.height)
                    
                        SignUpBirthDayView()
                            .id(SignUpViewPage.birthdayView)
                            .frame(width: size.width, height: size.height)
                    
                        SignUpProfileView()
                            .id(SignUpViewPage.profileView)
                            .frame(width: size.width, height: size.height)
                    }
                    .fontWeight(.bold)
                    .environmentObject(signUpViewModel)
                }
                .scrollDisabled(true)
                .onChange(of: signUpViewModel.viewPage) { _, newValue in
                    hideKeyboard()
                    
                    withAnimation {
                        scrollViewProxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
    }

    
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
