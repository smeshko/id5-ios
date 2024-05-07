import CoreLocation
import Entities
import Dependencies
import NetworkClient
import Endpoints

public extension LocationClient {
    static var live: LocationClient = {
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
                let stream = AsyncStream<LocationStateChangeEvent> { continuation in
                    delegate.streamContinuation = continuation
                    manager.startUpdatingLocation()
                }
                var event: LocationStateChangeEvent = .didUpdateLocations(locations: [])
                for await streamEvent in stream {
                    event = streamEvent
                    break
                }
                return event
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
            },
            stopMonitoringForChanges: {
                manager.stopUpdatingLocation()
            }
        )
    }()
}

public enum LocationStateChangeEvent {
    case didPause
    case didResume
    case didUpdateLocations(locations: [LocationClient.Location])
    case didFailWith(error: Error)
}

private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var streamContinuation: AsyncStream<LocationStateChangeEvent>.Continuation?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        streamContinuation?.yield(
            .didUpdateLocations(
                locations: locations.map(LocationClient.Location.init(location:))
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
