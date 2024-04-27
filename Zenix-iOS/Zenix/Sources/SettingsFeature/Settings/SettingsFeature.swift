import ComposableArchitecture
import LocalStorageClient
import Entities

@Reducer
public struct SettingsFeature {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var path = StackState<Path.State>()

        public init() {}
    }
    
    public enum Action {
        case path(StackAction<Path.State, Path.Action>)
    }
    
    @Dependency(\.localStorageClient) var localStorage
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .path:
                break
            }
            
            return .none
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}

public extension SettingsFeature {
    @Reducer
    struct Path {
        @ObservableState
        public enum State: Equatable {
            case debugSettings(DebugSettingsFeature.State)
        }
        
        public enum Action {
            case debugSettings(DebugSettingsFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.debugSettings, action: \.debugSettings) {
                DebugSettingsFeature()
            }
        }
    }
}
