import Foundation
import CoreLocation

class LocationDataManager: NSObject, ObservableObject {
    private var locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var coordinates: [CLLocationCoordinate2D] = []
    
    // 이동거리 계산
    var currentLocation: CLLocation?
    var totalDistance: CLLocationDistance = 0
    
    override init() {
        super.init()
        
        setupLocationManager()
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.startUpdatingLocation()
    }
}

extension LocationDataManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
            print("Location Request not determined")
            locationManager.requestAlwaysAuthorization()
            
        case .authorizedAlways:
            print("Location Request always authorized")
            
        case .authorizedWhenInUse:
            print("Location Request authorized when in use")
            
            
        case .restricted:
        // 사용자가 권한을 허용할 수 없는 상태
        // 보호자 통제 설정 등 위치 서비스를 제한한 경우
            print("Location Request restricted")
            
        case .denied:
            
            print("Location Request denied")
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        let lat = newLocation.coordinate.latitude
        let lon = newLocation.coordinate.longitude
        let newCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

        coordinates.append(newCoordinate)
        
        
        if let currentLocation {
            let distance = newLocation.distance(from: currentLocation)
            totalDistance += distance
        }
        
        currentLocation = newLocation
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
