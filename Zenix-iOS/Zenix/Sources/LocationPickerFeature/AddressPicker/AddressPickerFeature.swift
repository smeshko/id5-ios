import ComposableArchitecture
import Foundation
import Endpoints
import Entities
import NetworkClient

@Reducer
public struct AddressPickerFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var query: String
        var suggestions: [Places.Autocomplete.Response.Suggestion]
        var path = StackState<Path.State>()

        public init(
            query: String = "",
            suggestions: [Places.Autocomplete.Response.Suggestion] = []
        ) {
            self.query = query
            self.suggestions = suggestions
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case suggestionsReceived(Result<[Places.Autocomplete.Response.Suggestion], Error>)
        
        case binding(BindingAction<State>)
        case path(StackAction<Path.State, Path.Action>)

    }
    
    @Dependency(\.networkService) var networkService
    @Dependency(\.locationClient) var locationClient
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                locationClient.requestAuthorization()
                
            case .binding(\.query):
                return .run { [state] send in
                    let response: Places.Autocomplete.Response = try await networkService.sendRequest(to: ServiceEndpoint.addressAutocomplete(state.query))
                    await send(.suggestionsReceived(.success(response.suggestions)))
                } catch: { error, send in
                    await send(.suggestionsReceived(.failure(error)))
                }
                
            case .suggestionsReceived(.success(let suggestions)):
                state.suggestions = suggestions
                
            case .suggestionsReceived, .binding, .path:
                break
            }
            
            return .none
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}

extension AddressPickerFeature {
    @Reducer
    public struct Path {
        @ObservableState
        public enum State: Equatable {
            case addressConfirmation(AddressConfirmationFeature.State)
        }
        
        public enum Action {
            case addressConfirmation(AddressConfirmationFeature.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.addressConfirmation, action: \.addressConfirmation) {
                AddressConfirmationFeature()
            }
        }
    }
}

extension Places.Autocomplete.Response.Suggestion: Identifiable {
    public var id: UUID { UUID() }
}
