import ComposableArchitecture
import LocationClient

@Reducer
public struct DiscoverFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var locations: [Location] = []
        
        public init() {}
    }
    
    public enum Action {
        case didAppear
    }
    
    @Dependency(\.locationClient) var locationClient
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didAppear:
                locationClient.requestAuthorization()
                
                return .run { send in
                    for await event in locationClient.startMonitoringForChanges() {
                        switch event {
                        case .didUpdateLocations(let locations):
                            print(locations)
                        default:
                            print(event)
                        }
                    }
                }
            }
        }
    }
}
