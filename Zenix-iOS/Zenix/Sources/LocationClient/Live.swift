import CoreLocation
import Entities
import Dependencies
import NetworkClient
import Endpoints

public class LocationService: NSObject {
    private let manager = CLLocationManager()
    private let delegate = LocationManagerDelegate()

    public override init() {
        super.init()
        manager.delegate = delegate
    }
    
    public func requestAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse, .denied, .restricted:
            break
        @unknown default:
            break
        }
    }
    
    public func getLocation() -> AsyncStream<LocationStateChangeEvent> {
        AsyncStream<LocationStateChangeEvent> { continuation in
            delegate.streamContinuation = continuation
            manager.startUpdatingLocation()
        }
    }
    
//    public func convertToAddress() async throws -> Places.Search.Response {
//        
//    }
//    public func startMonitoringForChanges() -> AsyncStream<LocationStateChangeEvent> {
//        
//    }
    
}

private enum LocationServiceKey: DependencyKey {
    static let liveValue = LocationService()
//    static var previewValue = LocationService.preview
}

public extension DependencyValues {
    var locationService: LocationService {
        get { self[LocationServiceKey.self] }
        set { self[LocationServiceKey.self] = newValue }
    }
}


public extension LocationClient {
    static var live: LocationClient {
        let manager = CLLocationManager()
        let delegate = LocationManagerDelegate()
        @Dependency(\.networkService) var networkService
        
        manager.delegate = delegate
        
        return .init(
            requestAuthorization: {
                switch manager.authorizationStatus {
                case .notDetermined:
                    manager.requestWhenInUseAuthorization()
                case .authorizedAlways, .authorizedWhenInUse, .denied, .restricted:
                    break
                @unknown default:
                    break
                }
            },
            getLocation: {
                AsyncStream<LocationStateChangeEvent> { continuation in
                    delegate.streamContinuation = continuation
                    manager.startUpdatingLocation()
                }
            },
            convertToAddress: { location in
                try await networkService.sendRequest(
                    to: ServiceEndpoint.nearbyLocations(
                        location.longitude,
                        location.latitude
                    )
                )
            },
            startMonitoringForChanges: {
                AsyncStream<LocationStateChangeEvent> { continuation in
                    delegate.streamContinuation = continuation
                    manager.startMonitoringSignificantLocationChanges()
                }
            }
        )
    }
}

public struct Location: Equatable {
    public let latitude: Double
    public let longitude: Double
    public let accuracy: Double
    
    init(
        latitude: Double,
        longitude: Double,
        accuracy: Double
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
    }
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.accuracy = location.horizontalAccuracy
    }
}

public enum LocationStateChangeEvent {
    case didPause
    case didResume
    case didUpdateLocations(locations: [Location])
    case didFailWith(error: Error)
}

private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var streamContinuation: AsyncStream<LocationStateChangeEvent>.Continuation?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        streamContinuation?.yield(
            .didUpdateLocations(
                locations: locations.map(Location.init(location:))
            )
        )
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        streamContinuation?.yield(.didPause)
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        streamContinuation?.yield(.didResume)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        streamContinuation?.yield(.didFailWith(error: error))
    }
}
