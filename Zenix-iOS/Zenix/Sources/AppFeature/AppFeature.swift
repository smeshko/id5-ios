import ComposableArchitecture
import Entities
import TrackingClient

public struct AppFeature: Reducer {
    public static let store: StoreOf<AppFeature> = .init(
        initialState: .init(),
        reducer: AppFeature.init
    )
    
    init() {}
    
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
        case onAppear
    }
    
    @Dependency(\.trackingClient) var trackingClient
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                trackingClient.send(.applicationLaunched)
            }
            return .none
        }
    }
}
