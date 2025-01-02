import Foundation

struct Memory: Codable {
    var dailyMemories: [DailyMemory]?
    var walkingMemories: [DogWalkingMemory]?
}

struct DailyMemory: Memorable {
    var uid: String = UUID().uuidString
    var day: String
    var date: Date
    var text: String
    var photos: [String]
 
    static func defaultMemory() -> Self {
        return DailyMemory(
            day: "",
            date: .init(),
            text: "",
            photos: []
        )
    }
}

struct DogWalkingMemory: Memorable {
    var uid: String = UUID().uuidString
    var day: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var coordinates: [Coordinate]
    
    static func defaultMemory() -> Self {
        return DogWalkingMemory(
            day: "",
            date: .init(),
            startTime: .init(),
            endTime: .init(),
            coordinates: []
        )
    }
}

struct Coordinate: Codable {
    var latitude: String
    var longitude: String
}
