import ComposableArchitecture
import Endpoints
import Entities
import Foundation
import NetworkClient

@Reducer
public struct DiscoverCardFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: UUID { post.id }
        public let post: Post.List.Response
        public var thumbnail: Media.Download.Response?
        
        public init(
            post: Post.List.Response
        ) {
            self.post = post
        }
    }
    
    public enum Action {
        case onAppear
        
        case didReceiveImage(Result<Media.Download.Response, Error>)
    }
    
    @Dependency(\.networkService) var networkService
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [state] send in
                    let response: Media.Download.Response = try await networkService.sendRequest(to: MediaEndpoint.download(state.post.thumbnail))
                    
                    await send(.didReceiveImage(.success(response)))
                } catch: { error, send in
                    await send(.didReceiveImage(.failure(error)))
                }
                
            case .didReceiveImage(.success(let media)):
                state.thumbnail = media
                
            case .didReceiveImage:
                break
            }
            
            return .none
        }
    }
}
