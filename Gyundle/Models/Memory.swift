import Foundation
import CoreLocation

struct Memory: Codable {
    var dailyMemories: [DailyMemory]?
    var dogWalkingMemories: [DogWalkingMemory]?
}

struct DailyMemory: Memorable {
    var uid: String = UUID().uuidString
    var day: String
    var date: Date
    var text: String
    var photosURL: [String]
 
    static func defaultMemory() -> Self {
        return DailyMemory(
            day: .init(),
            date: .init(),
            text: .init(),
            photosURL: .init()
        )
    }
}

struct DogWalkingMemory: Memorable {
    var uid: String = UUID().uuidString
    var day: String
    var date: Date
    var endTime: Date
    var distance: String
    var calories: String
    var coordinates: [Coordinate]
    var markers: [DogWalkingMarker]
    
    static func defaultMemory() -> Self {
        return DogWalkingMemory(
            day: "",
            date: Date(),
            endTime: Date(),
            distance: "",
            calories: "",
            coordinates: .init(),
            markers: []
        )
    }
}

struct DogWalkingMarker: Identifiable, Codable {
    var id: String = UUID().uuidString
    var coordinate: Coordinate
    var memo: String
    var imageURL: String?
}

struct Coordinate: Codable {
    var latitude: String
    var longitude: String
    
    init(latitude: String = "", longitude: String = "") {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        guard let latitude = Double(latitude),
              let longitude = Double(longitude) else {
            return .init()
        }
              
        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
