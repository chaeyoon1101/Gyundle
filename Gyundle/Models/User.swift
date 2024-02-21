import Foundation

struct User: Codable {
    var id: String
    var email: String
    var name: String
    var photo: String
    var dateOfBirth: Date
}
