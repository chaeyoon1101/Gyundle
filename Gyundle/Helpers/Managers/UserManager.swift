import Foundation

final class UserManager: ObservableObject {
    static let shared = UserManager()
    private init() { }
    
    @Published var user: User?
    
    func fetchUserData(id: String) async throws {
        let fetchedUserData = try await FirebaseManager.shared.fetchUserData(id: id)
        
        await MainActor.run {
            self.user = fetchedUserData
        }
        print("fetch userData 성공")
    }
    
    // MARK: 유저 정보 DB에 업로드
    func uploadUserData(_ user: User) async throws {
        try await FirebaseManager.shared.uploadUserData(user)
        
        await MainActor.run {
            self.user = user
        }
    }
}
