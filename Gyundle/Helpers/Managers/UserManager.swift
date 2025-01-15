import Foundation
import FirebaseAuth

final class UserManager: ObservableObject {
    static let shared = UserManager()
    private init() { }
    
    @Published var user: User?
    
    func fetchUserData(id: String) async throws {
        let fetchedUser = try await FirebaseManager.shared.fetchUserData(id: id)
        
        user = fetchedUser
        print("fetch userData 성공")
    }
    
    // MARK: 유저 정보 DB에 업로드
    func uploadUserInfo(userData: UserInfoData) async {
        guard let currentUser = Auth.auth().currentUser else {
            print("can't upload user info. currnetUser is nil")
            return
        }
        
        let updatedUser = User(
            id: currentUser.uid,
            email: currentUser.email ?? currentUser.uid,
            name: userData.name,
            weight: userData.weight,
            photo: userData.photo,
            dateOfBirth: userData.dateOfBirth
        )
        
        do {
            try await FirebaseManager.shared.uploadUserInfo(user: updatedUser)
            
            await MainActor.run {
                user = updatedUser
            }
        } catch {
            print("유저 Info 업로드 실패")
        }
    }
}
