import Foundation

class UserInfoData: ObservableObject {
    @Published var id: String = ""
    @Published var email: String = ""
    @Published var name: String = ""
    @Published var photo: String = ""
    @Published var dateOfBirth: Date = Date()
}


extension UserInfoData: Equatable {
    static func == (lhs: UserInfoData, rhs: UserInfoData) -> Bool {
        return lhs.id == rhs.id &&
               lhs.email == rhs.email &&
               lhs.name == rhs.name &&
               lhs.photo == rhs.photo &&
               lhs.dateOfBirth == rhs.dateOfBirth
    }
}
