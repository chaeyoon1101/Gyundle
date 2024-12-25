import SwiftUI

struct SignUpProfileView: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject var imageViewModel = ImageViewModel()
    
    var body: some View {
        GeometryReader { let size = $0.size
        
            ZStack {
                if imageViewModel.isUploading {
                    LoadingView()
                }
                
                
                SignUpBackButton {
                    signUpViewModel.page = .birthdayView
                }
                .align(.topLeading)
                
                
                VStack {
                    
                    VStack(spacing: 24) {
                        Text("\(signUpViewModel.signUpData.name)의 예쁜 사진을 등록해주세요!")
                        
                        PhotoPickerView(
                            imageViewModel: imageViewModel,
                            uploadData: signUpViewModel.signUpData,
                            selectedImageURL: signUpViewModel.signUpData.photo
                        )
                    }
                    .position(x: size.width / 2, y: size.height / 4)
                    
                    Spacer()
                    
                    Button("완료") {
//                        authViewModel.uploadUserInfo(userData: signUpViewModel.signUpData)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .buttonStyle(SignUpViewButtonStyle())
                }
            }
        }
        .disabled(imageViewModel.isUploading)
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
