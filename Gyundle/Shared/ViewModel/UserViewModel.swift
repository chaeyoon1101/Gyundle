import Foundation
import FirebaseAuth

class UserViewModel: ObservableObject {
    @Published var user: User?
    
    func fetchUserData(id: String) async {
        do {
            let fetchedUser = try await FirebaseManager.shared.fetchUserData(id: id)
            
            user = fetchedUser
            print("UserViewModel.fetchUserData fetch userData 성공")
        } catch {
            print("UserViewModel.fetchUserData Error:", error.localizedDescription)
        }
    }
    
    // MARK: 유저 정보 DB에 업로드
    func uploadUserInfo(userData: UserInfoData) async {
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
        
        do {
            try await FirebaseManager.shared.uploadUserInfo(user: user)
            
            await fetchUserData(id: user.id)
        } catch {
            print("유저 Info 업로드 실패")
        }
    }
}
