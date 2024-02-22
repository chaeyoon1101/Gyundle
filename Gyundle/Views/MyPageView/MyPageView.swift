import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject var imageViewModel = ImageViewModel()
    @ObservedObject var userData = UserInfoData()
    
    var body: some View {
        ZStack {
            if imageViewModel.isUploading {
                LoadingView()
            }
            
            VStack {
                if let user = userViewModel.user {
                    VStack {
                        Text(user.name)
                        Text(user.email)
                        PhotoPickerView(
                            imageViewModel: imageViewModel,
                            uploadData: userData,
                            selectedImageURL: $userData.photo
                        )
                    }
                    .onAppear {
                        updateUserData(user: user)
                    }
                    
                    .onChange(of: userData) { newUserData in
                        userViewModel.uploadUserInfo(userData: newUserData)
                    }
                } else {
                    VStack {
                        Text("11")
                    }
                }
            }
        }
        .disabled(imageViewModel.isUploading)
    }
    
    private func updateUserData(user: User) {
        userData.id = user.id
        userData.email = user.email
        userData.name = user.name
        userData.photo = user.photo
        userData.dateOfBirth = user.dateOfBirth
    }
        
}

#Preview {
    MyPageView()
        .environmentObject(UserViewModel())
}
