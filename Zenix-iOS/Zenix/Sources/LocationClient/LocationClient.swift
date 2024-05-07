import Dependencies
import Entities
import CoreLocation

public struct LocationClient {
    
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

    public var requestAuthorization: () -> Void
    public var getLocation: () async throws -> LocationStateChangeEvent
    public var convertToAddress: (Location) async throws -> Places.Search.Response
    public var startMonitoringForChanges: () -> AsyncStream<LocationStateChangeEvent>
    public var stopMonitoringForChanges: () -> Void
}

extension LocationClient {
    static var preview: LocationClient = {
        .init(
            requestAuthorization: {},
            getLocation: {
                .didUpdateLocations(locations: [
                    LocationClient.Location(latitude: 10, longitude: 10, accuracy: 5)
                ])
            },
            convertToAddress: { _ in .init(places: []) },
            startMonitoringForChanges: {
                .init { cont in
                    for i in 1...10 {
                        cont.yield(.didUpdateLocations(locations: [
                            LocationClient.Location(latitude: Double(i), longitude: Double(i), accuracy: 5)
                        ]))
                    }
                }
            },
            stopMonitoringForChanges: {}
        )
    }()
}

private enum LocationClientKey: DependencyKey {
    static let liveValue = LocationClient.live
    static var previewValue = LocationClient.preview
}

public extension DependencyValues {
    var locationClient: LocationClient {
        get { self[LocationClientKey.self] }
        set { self[LocationClientKey.self] = newValue }
    }
}
