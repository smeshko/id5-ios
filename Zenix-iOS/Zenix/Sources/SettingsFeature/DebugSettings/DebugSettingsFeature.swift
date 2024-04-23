import ComposableArchitecture
import Entities
import SharedKit
import SettingsClient

@Reducer
public struct DebugSettingsFeature {
    public enum BaseURL: Hashable, CaseIterable {
        case local
        case staging
        case production
        case custom
        
        var name: String {
            switch self {
            case .local: "local"
            case .staging: "staging"
            case .production: "production"
            case .custom: "custom"
            }
        }
    }

    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var baseURL: BaseURL = .production
        var customHost: String = ""

        public init() {}
    }
    
    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
    }

    @Dependency(\.settingsClient) var settings
    @Dependency(\.environment) var environment

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.baseURL = base(for: (settings.string(.baseURL) ?? ""))
                if state.baseURL == .custom {
                    state.customHost = settings.string(.baseURL) ?? ""
                }

            case .binding(\.baseURL), .binding(\.customHost):
                let host = host(for: state.baseURL, custom: state.customHost)
                settings.setValue(host, .baseURL)
                
            case .binding:
                break
            }
            
            return .none
            
        }
    }
}

private extension DebugSettingsFeature {
    func base(for host: String) -> BaseURL {
        if host.contains("localhost") {
            return .local
        } else if host == environment.stagingHost {
            return .staging
        } else if host == environment.productionHost {
            return .production
        } else {
            return .custom
        }
    }
    
    func host(for base: BaseURL, custom: String) -> String {
        switch base {
        case .local: "localhost"
        case .staging: environment.stagingHost
        case .production: "prod"
        case .custom: custom
        }
    }
}
