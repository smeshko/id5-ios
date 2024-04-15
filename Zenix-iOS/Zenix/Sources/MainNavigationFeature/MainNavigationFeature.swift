import ComposableArchitecture
import Entities

@Reducer
public struct MainNavigationFeature {
    public enum Tab: String, Hashable, CaseIterable {
        case discover = "Discover"
        case myProfile = "My Profile"
        case settings = "Settings"
        case create = "Create"
    }
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {}
    
    public var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
