import Foundation

final class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var user: User?
    @Published var selectedDog: Dog? {
        didSet {
            setSelectedDog(selectedDog?.id)
        }
    }
    
    func fetchUserData(id: String) async throws {
        let fetchedUserData = try await FirebaseManager.shared.fetchUserData(id: id)
        
        await MainActor.run {
            self.user = fetchedUserData
            getSelectedDog()
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
    
    private func getSelectedDog() {
        let selectedDogID = UserDefaults.standard.string(forKey: "selectedDog")
        
        selectedDog = user?.dogs.first(where: { $0.id == selectedDogID }) ?? user?.dogs.first
    }
    
    private func setSelectedDog(_ id: String?) {
        if let id {
            UserDefaults.standard.set(id, forKey: "selectedDog")
        }
    }
}


