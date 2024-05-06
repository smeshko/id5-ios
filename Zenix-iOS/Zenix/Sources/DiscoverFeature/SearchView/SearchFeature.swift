import ComposableArchitecture
import Entities
import LocalStorageClient

@Reducer
public struct SearchFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var query: String = ""
        var recentSearches: [String] = []
        
        public init() {}
    }
    
    public enum Action: BindableAction {
        case onAppear
        
        case didTapCancelButton
        case didSubmitSearch
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.localStorageClient) var localStorage
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.recentSearches = localStorage.strings(.recentSearches)
                
            case .binding(\.query):
                print(state.query)
                
            case .didSubmitSearch:
                var copy = state.recentSearches
                if !copy.contains(state.query) {
                    if copy.count > 5 {
                        copy = Array(copy.dropFirst())
                    }
                    copy.append(state.query)
                    localStorage.setValue(copy, .recentSearches)
                }

            case .didTapCancelButton, .binding:
                break
            }
            
            return .none
        }
    }
}
