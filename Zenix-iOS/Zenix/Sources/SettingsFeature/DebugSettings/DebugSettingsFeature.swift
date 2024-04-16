import ComposableArchitecture
import Entities
import SettingsClient

@Reducer
public struct DebugSettingsFeature {
    public enum BaseURL: String, Hashable, CaseIterable {
        case local = "localhost"
        case staging = "shark-app-pwqpd.ondigitalocean.app"
        case production = ""
        
        var name: String {
            switch self {
            case .local: "local"
            case .staging: "staging"
            case .production: "production"
            }
        }
    }

    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var baseURL: BaseURL = .production

        public init() {}
    }
    
    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
    }

    @Dependency(\.settingsClient) var settings

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.baseURL = BaseURL(rawValue: settings.string(.baseURL) ?? "") ?? .staging

            case .binding(\.baseURL):
                settings.setValue(state.baseURL.rawValue, .baseURL)
                
            case .binding:
                break
            }
            
            return .none
            
        }
    }
}
