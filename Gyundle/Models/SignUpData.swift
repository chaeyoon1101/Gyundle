import Foundation

class SignUpData: ObservableObject {
    @Published var id: String = ""
    @Published var email: String = ""
    @Published var name: String = ""
    @Published var photo: String = ""
    @Published var dateOfBirth: Date = Date()
}
