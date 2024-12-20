import Foundation

struct Memory: Codable {
    var dailyMemories: [DailyMemory]?
    var walkingMemories: [DogWalkingMemory]?
}

struct DailyMemory: Codable, Memorable {
    var id: String
    var date: Date
    var text: String
    var photos: [String]
}

struct DogWalkingMemory: Codable, Memorable {
    var id: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var coordinates: [Coordinate]
}

struct Coordinate: Codable {
    var latitude: String
    var longitude: String
}
