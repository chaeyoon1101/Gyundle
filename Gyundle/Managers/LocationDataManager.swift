import Foundation

import CoreLocation

class LocationDataManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var coordinates: [CLLocationCoordinate2D] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            authorizationStatus = .authorizedAlways
            locationManager.requestLocation()
            break
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
            manager.requestAlwaysAuthorization()
            locationManager.requestLocation()
            break
            
        case .restricted:
            authorizationStatus = .restricted
            break
            
        case .denied:
            authorizationStatus = .denied
            break
            
        case .notDetermined:
            authorizationStatus = .notDetermined
            manager.requestAlwaysAuthorization()

            break
            
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            coordinates.append(coordinate)
            print(coordinates)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude  == rhs.latitude &&
               lhs.longitude == rhs.longitude
    }
}
