import ComposableArchitecture

@Reducer
public struct CameraFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
        case dismissButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss

    public var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
            case .dismissButtonTapped:
                return .run { _ in await self.dismiss() }
            }
        }
    }
}
