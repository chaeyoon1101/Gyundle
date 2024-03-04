import Foundation

struct DailyMemory: Codable {
    var date: Date
    var text: String
    var photos: [String]
}
