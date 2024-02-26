import Foundation

struct User: Codable {
    var id: String
    var email: String
    var name: String
    var photo: String
    var dateOfBirth: Date
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
               lhs.email == rhs.email &&
               lhs.name == rhs.name &&
               lhs.photo == rhs.photo &&
               lhs.dateOfBirth == rhs.dateOfBirth
    }
}
