//
//  MapCameraPosition.swift
//  Gyundle
//
//  Created by 임채윤 on 2/2/25.
//

import SwiftUI
import MapKit

extension MapCameraPosition {
    static func getCameraPosition(for coordinates: [Coordinate], span: Double = 1.75) -> MapCameraPosition {
        let latitudes = coordinates.compactMap { Double($0.latitude) }
        let longitudes = coordinates.compactMap { Double($0.longitude) }
        
        let minLatitude = latitudes.min() ?? 0
        let maxLatitude = latitudes.max() ?? 0
        let minLongitude = longitudes.min() ?? 0
        let maxLongitude = longitudes.max() ?? 0
        
        
        // 카메라 중심점
        let center = CLLocationCoordinate2D(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2
        )
        
        
        // 여유 간격
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLatitude - minLatitude) * span,
            longitudeDelta: (maxLongitude - minLongitude) * span
        )
        
        return MapCameraPosition.region(
            .init(center: center, span: span)
        )
    }
}
