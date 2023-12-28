import ComposableArchitecture
import Entities

public struct MainNavigationFeature: Reducer {
    public enum Tab: String, Hashable, CaseIterable {
        case discover = "Discover"
        case myProfile = "My Profile"
    }
    
    public init() {}
    
    public struct State: Equatable {
        var selectedTab: Tab = .discover
        
        public init() {
            print("init")
        }
    }
    
    public enum Action {
        case tabSelected(Tab)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                print(tab.rawValue)
                break
            }
            
            return .none
        }
    }
}
