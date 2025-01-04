import Foundation

struct Memory: Codable {
    var dailyMemories: [DailyMemory]?
    var dogWalkingMemories: [DogWalkingMemory]?
}

struct DailyMemory: Memorable {
    var uid: String = UUID().uuidString
    var day: String
    var date: Date
    var text: String
    var photos: [String]
 
    static func defaultMemory() -> Self {
        return DailyMemory(
            day: .init(),
            date: .init(),
            text: .init(),
            photos: .init()
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
            day: .init(),
            date: .init(),
            startTime: .init(),
            endTime: .init(),
            coordinates: .init()
        )
    }
}

struct Coordinate: Codable {
    var latitude: String
    var longitude: String
}
