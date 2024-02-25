import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @StateObject var locationDataManager = LocationDataManager()
    @State private var userLocation: CLLocationCoordinate2D = .init(latitude: 34, longitude: 34)
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    var body: some View {
        VStack {
            let locationAuthStatus = locationDataManager.locationManager.authorizationStatus
            
            if locationAuthStatus == .authorizedWhenInUse {
                VStack {
                    Map(position: $cameraPosition) {
                        UserAnnotation()
 
                        if !locationDataManager.coordinates.isEmpty {
                            MapPolyline(coordinates: locationDataManager.coordinates, contourStyle: .geodesic)
                                .stroke(Color.bg, lineWidth: 4)
                        }
                    }
                    .mapControls {
                        MapUserLocationButton()
                        MapPitchToggle()
                        MapCompass()
                    }
                    .mapStyle(.standard(elevation: .realistic))
                }
                .onAppear {
                    if let lat = locationDataManager.locationManager.location?.coordinate.latitude.description,
                       let lon = locationDataManager.locationManager.location?.coordinate.longitude.description {
                        userLocation = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
                        let region = MKCoordinateRegion(
                            center: userLocation,
                            latitudinalMeters: 400,
                            longitudinalMeters: 400
                        )
                        cameraPosition = .userLocation(
                            fallback: .region(region)
                        )
                    }
                }
                .onChange(of: locationDataManager.coordinates) { _, coordinates in
                    if let location = coordinates.last {
                        withAnimation {
                            userLocation = location
                        }
                    }
                }
                Text("(\(userLocation.latitude), \(userLocation.longitude))")
                    .padding()

            } else if locationAuthStatus == .restricted || locationAuthStatus == .denied {
                Text("Current location data was restricted or denied.")
            } else {
                Text("Finding your location...")
                ProgressView()
            }
        }
    }
    
    private var myLocationAnnotation: some View {
        ZStack {
            Circle()
                .frame(width: 32, height: 32)
                .foregroundStyle(Color.blue.opacity(0.25))
            
            Circle()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.white)
            
            Circle()
                .frame(width: 12, height: 12)
                .foregroundStyle(Color.blue)
        }
    }
}

//extension CLLocationCoordinate2D {
//    static var userLocation: CLLocationCoordinate2D {
//        return .init(latitude: 34, longitude: 34)
//    }
//}
//
//extension MKCoordinateRegion {
//    static var userRegion: MKCoordinateRegion {
//        return .init(center: .userLocation,
//                     latitudinalMeters: 10000,
//                     longitudinalMeters: 10000)
//    }
//}

extension CLLocationCoordinate2D: Hashable {
//    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
//        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
//    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}
