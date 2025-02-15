import Foundation

struct User: Codable {
    var id: String
    var email: String
    var dogs: [Dog]
}

struct Dog: Codable {
    var id: String = UUID().uuidString
    var name: String
    var gender: Gender
    var weight: Double
    var photoURL: String?
    var dateOfBirth: Date
}

enum Gender: String, Codable {
    case male
    case female
    case unspecified
    
    var stringValue: String {
        switch self {
        case .male:
            "남아"
        case .female:
            "여아"
        case .unspecified:
            ""
        }
    }
}

extension Dog: Equatable {
    static func == (lhs: Dog, rhs: Dog) -> Bool {
        return lhs.id == rhs.id
    }
}
