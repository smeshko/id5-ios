import ComposableArchitecture
import PostDetailsFeature
import Endpoints
import Entities
import NetworkClient
import SharedKit

@Reducer
public struct DiscoverFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var cards: IdentifiedArrayOf<DiscoverCardFeature.State>
        var path = StackState<Path.State>()
        var error: String?

        public init(
            cards: IdentifiedArrayOf<DiscoverCardFeature.State> = []
        ) {
            self.cards = cards
        }
    }
    
    public enum Action {
        case didAppear
        
        case didReceivePosts(Result<[Post.List.Response], Error>)
        case cards(IdentifiedActionOf<DiscoverCardFeature>)
        
        case path(StackAction<Path.State, Path.Action>)
    }

    @Dependency(\.networkService) var networkService

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didAppear:
                guard state.cards.isEmpty else { break }
                
                return .run { send in
                    let response: [Post.List.Response] = try await networkService.sendRequest(to: PostEndpoint.allPosts)
                    await send(.didReceivePosts(.success(response)))
                } catch: { error, send in
                    await send(.didReceivePosts(.failure(error)))
                }
                
            case .didReceivePosts(.success(let posts)):
                state.cards = posts.map(DiscoverCardFeature.State.init(post:)).identified
            
            case .didReceivePosts(.failure(let error)):
                if let error = error as? ZenixError {
                    state.error = error.reason
                }
                
            case .cards, .path:
                break
            }
            
            return .none
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
        .forEach(\.cards, action: \.cards) {
            DiscoverCardFeature()
        }
    }
}

public extension DiscoverFeature {
    @Reducer
    struct Path {
        @ObservableState
        public enum State: Equatable {
            case postDetails(PostDetailsFeature.State)
        }
        
        public enum Action {
            case postDetails(PostDetailsFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.postDetails, action: \.postDetails) {
                PostDetailsFeature()
            }
        }
    }
}

extension Array where Element: Identifiable {
    var identified: IdentifiedArrayOf<Element> {
        IdentifiedArray(uniqueElements: self)
    }
}
