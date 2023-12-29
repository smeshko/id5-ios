import ComposableArchitecture
import Entities

public struct MainNavigationFeature: Reducer {
    public enum Tab: String, Hashable, CaseIterable {
        case discover = "Discover"
        case myProfile = "My Profile"
        case settings = "Settings"
    }
    
    public init() {}
    
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
    }
    
    public var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
