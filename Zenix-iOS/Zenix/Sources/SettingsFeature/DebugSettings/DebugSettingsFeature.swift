import ComposableArchitecture
import Entities
import SharedKit
import LocalStorageClient

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

    @Dependency(\.localStorageClient) var localStorage
    @Dependency(\.environment) var environment

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.baseURL = base(for: (localStorage.string(.baseURL) ?? ""))
                if state.baseURL == .custom {
                    state.customHost = localStorage.string(.baseURL) ?? ""
                }

            case .binding(\.baseURL), .binding(\.customHost):
                let host = host(for: state.baseURL, custom: state.customHost)
                localStorage.setValue(host, .baseURL)
                
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
