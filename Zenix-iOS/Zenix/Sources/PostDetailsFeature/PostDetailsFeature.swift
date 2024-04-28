import ComposableArchitecture
import Endpoints
import Entities
import Foundation
import NetworkClient
import SharedKit

extension Comment.Create.Request: JSONEncodable {}

@Reducer
public struct PostDetailsFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        let postId: UUID
        var post: Post.Detail.Response? = nil
        var comments: [Comment.List.Response] = []
        var images: [Media.Download.Response] = []
        var newComment: String
        var error: String?
        
        public init(
            postId: UUID,
            newComment: String = ""
        ) {
            self.postId = postId
            self.newComment = newComment
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case didCommitComment
        
        case binding(BindingAction<State>)
        case didReceivePostDetails(Result<Post.Detail.Response, Error>)
        case didReceiveComments(Result<[Comment.List.Response], Error>)
        case didReceiveImage(Result<Media.Download.Response, Error>)
    }
    
    @Dependency(\.networkService) var networkService
    @Dependency(\.authorizedNetworkService) var authNetworkService
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [state] send in
                    let response: Post.Detail.Response = try await networkService.sendRequest(to: PostEndpoint.postDetails(state.postId))
                    
                    await send(.didReceivePostDetails(.success(response)))
                } catch: { error, send in
                    await send(.didReceivePostDetails(.failure(error)))
                }
                
            case .didReceivePostDetails(.success(let post)):
                state.post = post
                state.comments = post.comments
                return .concatenate(
                    post.imageIDs.map({ id in
                        return Effect.run { send in
                            let response: Media.Download.Response = try await networkService.sendRequest(to: MediaEndpoint.download(id))
                            await send(.didReceiveImage(.success(response)))
                        } catch: { error, send in
                            await send(.didReceiveImage(.failure(error)))
                        }
                    })
                )
                
            case .didCommitComment:
                return .run { [state] send in
                    let comment = Comment.Create.Request(text: state.newComment).encoded
                    let response: [Comment.List.Response] = try await authNetworkService.sendRequest(to: PostEndpoint.createComment(comment, state.postId))
                    
                    await send(.didReceiveComments(.success(response)))
                } catch: { error, send in
                    await send(.didReceiveComments(.failure(error)))
                }
                
            case .didReceiveComments(.success(let comments)):
                state.newComment = ""
                state.comments = comments
                
            case .didReceiveImage(.success(let image)):
                state.images.append(image)
                
            case .didReceivePostDetails(.failure(let error)), 
                    .didReceiveImage(.failure(let error)),
                    .didReceiveComments(.failure(let error)):
                if let error = error as? ZenixError {
                    state.error = error.reason
                }
                
            case .binding:
                break
            }
            
            return .none
        }
    }
}
