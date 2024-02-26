import Foundation

class UserViewModel: ObservableObject {
    @Published var user: User?
    
    func fetchUserData(id: String) {
        FirebaseManager.shared.fetchUserData(id: id) { result in
            switch result {
            case .success(let user):
                self.user = user
                print("UserViewModel.fetchUserData fetch userData 성공")
            case .failure(let error):
                print("UserViewModel.fetchUserData Error:", error.localizedDescription)
            }
        }
    }
    
    func uploadUserInfo(userData: UserInfoData) {
        let user = User(
            id: userData.id,
            email: userData.email,
            name: userData.name,
            photo: userData.photo,
            dateOfBirth: userData.dateOfBirth
        )
        
        FirebaseManager.shared.uploadUserInfo(user: user) { error in
            print("Uploading User info")
            if let error = error {
                print("error", error)
                return
            }
            
            self.fetchUserData(id: user.id)
        }
    }
}
