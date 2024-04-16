import ComposableArchitecture
import Entities
import Foundation

@Reducer
public struct DiscoverCardFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: UUID { post.id }
        public let post: Post.List.Response
        
        public init(
            post: Post.List.Response
        ) {
            self.post = post
        }
    }
    
    public enum Action {
        case onAppear
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                break
            }
            
            return .none
        }
    }
}
