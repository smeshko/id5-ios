import Dependencies
import Entities

public struct LocationClient {
    
    public var requestAuthorization: () -> Void
    public var getLocation: () -> AsyncStream<LocationStateChangeEvent>
    public var convertToAddress: (Location) async throws -> Places.Search.Response
    public var startMonitoringForChanges: () -> AsyncStream<LocationStateChangeEvent>
}

extension LocationClient {
    static var preview: LocationClient = {
        .init(
            requestAuthorization: {},
            getLocation: {
                .init { cont in
                    cont.yield(.didUpdateLocations(locations: [
                        Location(latitude: 10, longitude: 10, accuracy: 5)
                    ]))
                }
            },
            convertToAddress: { _ in .init(places: []) },
            startMonitoringForChanges: {
                .init { cont in
                    for i in 1...10 {
                        cont.yield(.didUpdateLocations(locations: [
                            Location(latitude: Double(i), longitude: Double(i), accuracy: 5)
                        ]))
                    }
                }
            }
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
