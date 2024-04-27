import ComposableArchitecture
import Endpoints
import Entities
import NetworkClient

@Reducer
public struct AddressConfirmationFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        let placeId: String
        var address: String = ""
        
        public init(
            placeId: String
        ) {
            self.placeId = placeId
        }
    }
    
    public enum Action {
        case onAppear
        case addressReceived(Result<Places.Geocode.Response, Error>)
    }
    
    @Dependency(\.networkService) var networkService
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [state] send in
                    let result: Places.Geocode.Response = try await networkService.sendRequest(to: ServiceEndpoint.geocode(state.placeId))
                    
                    await send(.addressReceived(.success(result)))
                } catch: { error, send in
                    await send(.addressReceived(.failure(error)))
                }
                
            case .addressReceived(.success(let address)):
                state.address = address.address
                
            case .addressReceived:
                break
            }
            
            return .none
        }
    }
}
