import ComposableArchitecture
import SharedKit

@Reducer
public struct DiscoverFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var cards: IdentifiedArrayOf<DiscoverCardFeature.State>
        
        public init(
            cards: IdentifiedArrayOf<DiscoverCardFeature.State> = []
        ) {
            self.cards = cards
        }
    }
    
    public enum Action {
        case didAppear
        
        case cards(IdentifiedActionOf<DiscoverCardFeature>)
    }
        
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didAppear:
                state.cards = [
                    .init(post: .mock()),
                    .init(post: .mock()),
                    .init(post: .mock()),
                    .init(post: .mock())
                ]
                
            case .cards:
                break
            }
            
            return .none
        }
        .forEach(\.cards, action: \.cards) {
            DiscoverCardFeature()
        }
    }
}
