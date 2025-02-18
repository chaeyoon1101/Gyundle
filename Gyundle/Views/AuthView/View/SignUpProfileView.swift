import SwiftUI
import PhotosUI

struct SignUpProfileView: View {
    @EnvironmentObject private var signUpViewModel: SignUpViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    // Photo Properties
    @State private var selection: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var isUploading: Bool = false

    var body: some View {
        VStack {
            VStack(spacing: 24) {
                Text("\(signUpViewModel.dog.name)에 대해 더 자세히 알려주세요!")
                    .lineLimit(2)

                ProfileImagePicker()
                
                GenderPicker()
                
                WeightPicker(weight: $signUpViewModel.dog.weight)
            }
            .padding(.top, 150)
                
            Spacer()
            
            Button("완료") {
                Task {
                    guard signUpViewModel.dog.weight != 0.0 else {
                        signUpViewModel.presentError(message: "몸무게를 입력해주세요.")
                        return
                    }
                    
                    await signUpViewModel.signUp(onSuccess: {
                        authViewModel.status = .loggedIn
                    })
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .buttonStyle(SignUpViewButtonStyle())
        }
        .overlay(alignment: .topLeading) {
            SignUpBackButton {
                signUpViewModel.viewPage = .birthdayView
            }
        }
        .toastView(isShowing: $signUpViewModel.showError, message: signUpViewModel.errorMessage)
        .progressView(isShowing: $isUploading)
    }
    
    @ViewBuilder
    private func ProfileImagePicker() -> some View {
        PhotosPicker(
            selection: $selection,
            matching: .images,
            preferredItemEncoding: .automatic,
            photoLibrary: .shared()
        ) {
            if let uiImage = profileImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(.circle)
            } else {
                Image(systemName: "dog.fill")
                    .frame(width: 120, height: 120)
                    .foregroundStyle(ColorConstant.fgPrimary)
                    .background(ColorConstant.bgContent, in: .circle)
            }
        }
        .onChange(of: selection) { _, newValue in
            Task {
                defer { isUploading = false }
                isUploading = true
                
                if let data = try await selection?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        self.profileImage = UIImage(data: data)
                    }
                    
                    let photoURL = try await FirebaseManager.shared.uploadPhoto(
                        with: data,
                        to: PhotoStorage.profile.folderName
                    )
                    
                    await MainActor.run {
                        signUpViewModel.dog.photoURL = photoURL
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func GenderPicker() -> some View {
        HStack(spacing: 15) {
            Text("♀")
                .font(.system(size: 24))
                .foregroundStyle(signUpViewModel.dog.gender == .female ? .pink : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Capsule()
                        .fill(signUpViewModel.dog.gender == .female ? .pink.opacity(0.08) : ColorConstant.bgContent)
                        .stroke(signUpViewModel.dog.gender == .female ? .pink : .gray, lineWidth: 3)
                )
                .onTapGesture {
                    signUpViewModel.dog.gender = .female
                }
            
            Text("♂")
                .font(.system(size: 24))
                .foregroundStyle(signUpViewModel.dog.gender == .male ? .blue : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Capsule()
                        .fill(signUpViewModel.dog.gender == .male ? .blue.opacity(0.12) : ColorConstant.bgContent)
                        .stroke(signUpViewModel.dog.gender == .male ? .blue : .gray, lineWidth: 3)
                )
                .onTapGesture {
                    signUpViewModel.dog.gender = .male
                }
        }
        .padding(.horizontal)
    }
}

#Preview {
    SignUpProfileView()
        .environmentObject(SignUpViewModel())
        .environmentObject(AuthViewModel())
}
