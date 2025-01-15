import Foundation

struct User: Codable {
    var id: String
    var email: String
    var name: String
    var weight: Double
    var photo: String
    var dateOfBirth: Date
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
