import Foundation

struct Memory: Codable {
    var dailyMemories: [DailyMemory]
}

struct DailyMemory: Codable {
    var id: String
    var date: Date
    var text: String
    var photos: [String]
}
