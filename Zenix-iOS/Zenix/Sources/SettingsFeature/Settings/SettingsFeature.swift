import ComposableArchitecture
import SettingsClient
import Entities

public struct SettingsFeature: Reducer {
    
    public init() {}
    
    public struct State: Equatable {
        var path = StackState<DebugSettingsFeature.State>()

        public init() {}
    }
    
    public enum Action {
        case path(StackAction<DebugSettingsFeature.State, DebugSettingsFeature.Action>)
    }
    
    @Dependency(\.settingsClient) var settings
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .path:
                break
            }
            
            return .none
        }
        .forEach(\.path, action: /Action.path) {
            DebugSettingsFeature()
        }
    }
}
