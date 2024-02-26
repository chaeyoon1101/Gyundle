import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject var imageViewModel = ImageViewModel()
    @ObservedObject var userData = UserInfoData()
    
    var body: some View {
        ZStack {
            VStack {
                if let user = userViewModel.user {
                    VStack {
                        Text(user.name)
                        Text(user.email)
                        PhotoPickerView(
                            imageViewModel: imageViewModel,
                            uploadData: userData,
                            selectedImageURL: user.photo
                        )
                    }
                    .onAppear {
                        updateUserData(user: user)
                    }
                    .onChange(of: user) { _, _ in
                        updateUserData(user: user)
                    }
                } else {
                    VStack {
                        Text("11")
                    }
                }
            }
            if imageViewModel.isUploading {
                LoadingView()
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
