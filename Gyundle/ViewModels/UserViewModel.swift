import Foundation

class UserViewModel: ObservableObject {
    @Published var user: User?
    
    func fetchUserData(id: String) {
        FirebaseManager.shared.fetchUserData(id: id) { result in
            switch result {
            case .success(let user):
                self.user = user
                print("UserViewModel.fetchUserData fetch userData 성공")
                print(user)
            case .failure(let error):
                print("UserViewModel.fetchUserData Error:",error.localizedDescription)
            }
        }
    }
}
