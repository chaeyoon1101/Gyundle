import SwiftUI

struct SignUpProfileView: View {
    @ObservedObject var signUpData: UserInfoData
    @StateObject var imageViewModel = ImageViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Binding var pageId: SignUpViewPageId
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if imageViewModel.isUploading {
                    LoadingView()
                }
                
                backButton
                    .position(x: 30, y: 30)
                
                VStack {
                    VStack(spacing: 24) {
                        Text("\(signUpData.name)의 예쁜 사진을 등록해주세요!")
                        
                        PhotoPickerView(imageViewModel: imageViewModel, uploadData: signUpData, selectedImageURL: signUpData.photo)
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 4)
                    
                    Spacer()
                    
                    Button("완료") {
                        authViewModel.uploadUserInfo(userData: signUpData)
                    }
                    .frame(width: geometry.size.width * 0.9)
                    .buttonStyle(SignUpViewButtonStyle())
                }
            }
        }
        .disabled(imageViewModel.isUploading)
    }

    var backButton: some View {
        Button {
            pageId = .birthdayView
        } label: {
            Image(systemName: "chevron.left")
        }
        .frame(width: 48, height: 48)
        .background(Color.secondary)
        .opacity(0.3)
        .foregroundStyle(.fg)
        .font(.title)
        .cornerRadius(5)
    }
}

#Preview {
    SignUpProfileView(signUpData: UserInfoData(), pageId: .constant(.profileView))
}
