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
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uid == rhs.uid &&
        lhs.day == rhs.day &&
        lhs.date == rhs.date &&
        lhs.text == rhs.text &&
        lhs.photosURL == rhs.photosURL
    }
}

struct DogWalkingMemory: Memorable {
    var uid: String = UUID().uuidString
    var day: String
    var date: Date
    var title: String
    var time: String
    var distance: String
    var speed: String
    var calories: String
    var coordinates: [Coordinate]
    var markers: [DogWalkingMarker]
    
    static func defaultMemory() -> Self {
        return DogWalkingMemory(
            day: "",
            date: Date(),
            title: "",
            time: "",
            distance: "",
            speed: "",
            calories: "",
            coordinates: .init(),
            markers: []
        )
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uid == rhs.uid &&
        lhs.day == rhs.day &&
        lhs.date == rhs.date &&
        lhs.title == rhs.title &&
        lhs.coordinates == rhs.coordinates &&
        lhs.markers == rhs.markers
    }
}

struct DogWalkingMarker: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var coordinate: Coordinate
    var memo: String
    var imageURL: String?
    
    init(coordinate: Coordinate = .init(), memo: String = "", imageURL: String? = nil) {
        self.coordinate = coordinate
        self.memo = memo
        self.imageURL = imageURL
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
        lhs.coordinate == rhs.coordinate &&
        lhs.memo == rhs.memo &&
        lhs.imageURL == rhs.imageURL
    }
}

struct Coordinate: Codable, Equatable {
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
