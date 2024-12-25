import Foundation
import FirebaseAuth

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
    
    // MARK: 유저 정보 DB에 업로드
    func uploadUserInfo(userData: UserInfoData)  {
        guard let currentUser = Auth.auth().currentUser else {
            print("can't upload user info. currnetUser is nil")
            return
        }
        
        let user = User(
            id: currentUser.uid,
            email: currentUser.email ?? currentUser.uid,
            name: userData.name,
            photo: userData.photo,
            dateOfBirth: userData.dateOfBirth
        )
        
        FirebaseManager.shared.uploadUserInfo(user: user) { error in
            if let error {
                print("유저 정보 업로드 실패: ", error.localizedDescription)
                return
            }
            
            self.fetchUserData(id: user.id)
        }
    }
}
