import ComposableArchitecture
import Endpoints
import Entities
import Foundation
import MediaClient

@Reducer
public struct DiscoverCardFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: UUID { post.id }

        public let post: Post.List.Response
        public let thumbnailID: UUID
        public let avatarID: UUID?
        
        public init(
            post: Post.List.Response
        ) {
            self.post = post
            self.thumbnailID = post.thumbnail
            self.avatarID = post.user.avatar
        }
    }
    
    public enum Action {
        case onAppear
    }
    
    @Dependency(\.mediaClient) var mediaClient
    
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
