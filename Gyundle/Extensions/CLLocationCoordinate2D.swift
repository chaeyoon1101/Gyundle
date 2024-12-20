//
//  CLLocationCoordinate2D.swift
//  Gyundle
//
//  Created by 임채윤 on 3/26/24.
//

import CoreLocation

extension CLLocationCoordinate2D {
    func toCoordinate() -> Coordinate {
        let coordinate = Coordinate(latitude: latitude.description, longitude: longitude.description)
        
        return coordinate
    }
}
