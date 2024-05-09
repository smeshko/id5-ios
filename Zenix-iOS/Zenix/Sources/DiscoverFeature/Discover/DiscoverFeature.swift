import AccountClient
import ComposableArchitecture
import Entities
import PostClient
import PostDetailsFeature
import SharedKit

@Reducer
public struct DiscoverFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        @Presents var search: SearchFeature.State?
        var cards: IdentifiedArrayOf<DiscoverCardFeature.State>
        var path = StackState<Path.State>()
        var categoriesState = CategoriesFeature.State()
        var error: String?
        var searchQuery: String = ""
        var address: String = ""
        var leftColumn: IdentifiedArrayOf<DiscoverCardFeature.State> = []
        var rightColumn: IdentifiedArrayOf<DiscoverCardFeature.State> = []

        public init(
            cards: IdentifiedArrayOf<DiscoverCardFeature.State> = []
        ) {
            self.cards = cards
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case fetchPostsAndUser
        
        case didReceivePosts(Result<[Post.List.Response], Error>)
        case didReceiveUserInfo(Result<User.Detail.Response, Error>)
        case cards(IdentifiedActionOf<DiscoverCardFeature>)
        case categoriesAction(CategoriesFeature.Action)
        
        case didTapSearchButton
        
        case searchAction(PresentationAction<SearchFeature.Action>)
        case path(StackAction<Path.State, Path.Action>)
        case binding(BindingAction<State>)
    }

    @Dependency(\.postClient) var postClient
    @Dependency(\.accountClient) var accountClient
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.categoriesState, action: \.categoriesAction) {
            CategoriesFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.cards.isEmpty else { break }
                return .send(.fetchPostsAndUser)
                
            case .fetchPostsAndUser:
                state.cards = []
                return .concatenate(
                    .run { send in
                        let userInfo = try await accountClient.accountInfo(false)
                        await send(.didReceiveUserInfo(.success(userInfo)))
                    } catch: { error, send in
                        await send(.didReceiveUserInfo(.failure(error)))
                    },
                    .run { send in
                        let response: [Post.List.Response] = try await postClient.all()
                        await send(.didReceivePosts(.success(response)))
                    } catch: { error, send in
                        await send(.didReceivePosts(.failure(error)))
                    }
                )
                
            case .didReceivePosts(.success(let posts)):
                state.error = nil
                state.cards = posts
                    .sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending })
                    .map(DiscoverCardFeature.State.init(post:)).identified
                if state.cards.count > 1 {
                    let split = state.cards.split()
                    state.leftColumn = split.first?.identified ?? []
                    state.rightColumn = split.last?.identified ?? []
                }
            
            case .didReceivePosts(.failure(let error)):
                if let error = error as? ZenixError {
                    state.error = error.reason
                }
                
            case .didReceiveUserInfo(.success(let userInfo)):
                state.address = userInfo.location?.address ?? ""
                
            case .didTapSearchButton:
                state.search = .init()
                
            case .searchAction(let action):
                switch action {
                case .presented(.didTapCancelButton):
                    state.search = nil
                default:
                    break
                }
                
            case .categoriesAction:
                break
                
            case .cards, .path, .binding, .didReceiveUserInfo:
                break
            }
            
            return .none
        }
        .ifLet(\.$search, action: \.searchAction) {
            SearchFeature()
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

private extension IdentifiedArray where Element: Identifiable {
    func split(into columns: Int = 2) -> [[Element]] {
        var result: [[Element]] = []
        
        var list1: [Element] = []
        var list2: [Element] = []
        
        self.forEach { element in
            let index = self.firstIndex { $0.id == element.id }
            
            if let index = index {
                if index % 2 == 0  {
                    list1.append(element)
                } else {
                    list2.append(element)
                }
            }
        }
        result.append(list1)
        result.append(list2)
        return result
    }
}
