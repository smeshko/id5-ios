import ComposableArchitecture
import Entities
import ContestClient

public struct DiscoverFeature: Reducer {
    @Dependency(\.contestClient) var contestClient
    public init() {}
    
    public struct State: Equatable {
        var contests: IdentifiedArrayOf<ContestCardFeature.State>
        
        public init(
            contests: IdentifiedArrayOf<ContestCardFeature.State> = []
        ) {
            self.contests = contests
        }
    }
    
    public enum Action {
        case didAppear
        
        case didReceiveContests([Contest.List.Response])
        
        case row(id: ContestCardFeature.State.ID, action: ContestCardFeature.Action)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didAppear:
                return .run { send in
                    let contests = try await contestClient.allContests()
                    await send(.didReceiveContests(contests))
                }
                
            case .didReceiveContests(let contests):
                state.contests = IdentifiedArray(
                    uniqueElements: contests.map(ContestCardFeature.State.init(contest:))
                )
            case .row:
                break
            }
            
            return .none
        }
        .forEach(\.contests,action: /Action.row) {
            ContestCardFeature()
        }
    }
}
