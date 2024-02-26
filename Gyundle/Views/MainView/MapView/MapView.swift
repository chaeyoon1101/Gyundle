import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var locationDataManager = LocationDataManager()
    @State private var userLocation: CLLocationCoordinate2D = .init()
    @State private var cameraPosition: MapCameraPosition = .automatic
    
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
                        userLocation = CLLocationCoordinate2D(
                            latitude: Double(lat) ?? 0.0,
                            longitude: Double(lon) ?? 0.0
                        )
                        
                        let region = MKCoordinateRegion(
                            center: userLocation,
                            latitudinalMeters: 400,
                            longitudinalMeters: 400
                        )
                        
                        cameraPosition = .region(region)
                    }
                }
                .onChange(of: locationDataManager.coordinates) { _, coordinates in
                    if let location = coordinates.last {
                        userLocation = location
                    }
                }
            } else if locationAuthStatus == .restricted || locationAuthStatus == .denied {
                Text("Current location data was restricted or denied.")
            } else {
                Text("Finding your location...")
                ProgressView()
            }
        }
    }
}

extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}
