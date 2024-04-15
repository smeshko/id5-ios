import ComposableArchitecture
import LocationClient
import Entities

@Reducer
public struct LocationPickerFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var places: [Places.Place] = []
        
        public init() {}
    }
    
    public enum Action {
        case didUpdatePlaces(Result<Places.Search.Response, Error>)
        case onAppear
    }
    
    @Dependency(\.locationClient) var locationClient
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                locationClient.requestAuthorization()
                return .run { send in
                    for await location in locationClient.getLocation() {
                        if case let .didUpdateLocations(locations) = location, let location = locations.first {
                            do {
                                let places = try await locationClient.convertToAddress(location)
                                await send(.didUpdatePlaces(.success(places)))
                            } catch {
                                await send(.didUpdatePlaces(.failure(error)))
                            }
                        }
                    }
                }
                
            case .didUpdatePlaces(.success(let response)):
                state.places = response.places
                
            case .didUpdatePlaces(.failure):
                break
            }
            
            return .none
        }
    }
}
