import ComposableArchitecture
import TelemetryClient

public struct TrackingClient {
    public enum Signal {
        case event(Event)
        case error(Error)
        case view(View)
        
        var rawValue: String {
            switch self {
            case .event(let event): event.rawValue
            case .error(let error): error.rawValue
            case .view(let view): view.rawValue
            }
        }
    }
    
    public var send: (Signal) -> Void
}

public extension TrackingClient {
    static let live: TrackingClient = {
        let configuration = TelemetryManagerConfiguration(appID: "657726A8-818B-47DF-95E0-9A3C16F40F72")
        TelemetryManager.initialize(with: configuration)

        return .init(
            send: { signal in
                TelemetryManager.send(signal.rawValue)
            })
    }()
    
    static let preview: TrackingClient = {
        return .init(send: { signal in
            print("signal sent: \(signal)")
        })
    }()
}

private enum TrackingClientKey: DependencyKey {
    static let liveValue = TrackingClient.live
    static var previewValue = TrackingClient.preview
}

public extension DependencyValues {
    var trackingClient: TrackingClient {
        get { self[TrackingClientKey.self] }
        set { self[TrackingClientKey.self] = newValue }
    }
}
