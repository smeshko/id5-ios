import AccountClient
import ComposableArchitecture
import Endpoints
import Entities
import Foundation
import MediaClient
import PostClient
import SharedKit

@Reducer
public struct PostDetailsFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        let postId: UUID
        var post: Post.Detail.Response? = nil
        var comments: [Comment.List.Response] = []
        var images: [Media.Download.Response] = []
        var isSignedIn = false
        var isFollowing = false
        var imageIDs: [UUID] = []
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
        case didTapFollowButton
        
        case binding(BindingAction<State>)
        case didReceivePostDetails(Result<(Post.Detail.Response, User.Detail.Response), Error>)
        case didReceiveComments(Result<[Comment.List.Response], Error>)
        case didReceiveImage(Result<Media.Download.Response, Error>)
        case didFinishFollowRequest(Result<Void, Error>)
    }
    
    @Dependency(\.postClient) var postClient
    @Dependency(\.mediaClient) var mediaClient
    @Dependency(\.accountClient) var accountClient
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isSignedIn = accountClient.isSignedIn()
                return .run { [state] send in
                    let response = try await postClient.details(state.postId)
                    let userInfo = try await accountClient.accountInfo(false)

                    await send(.didReceivePostDetails(.success((response, userInfo))))
                } catch: { error, send in
                    await send(.didReceivePostDetails(.failure(error)))
                }
                
            case .didReceivePostDetails(.success(let response)):
                let post = response.0
                let user = response.1
                state.post = post
                state.comments = post.comments
                state.imageIDs = post.imageIDs
                state.isFollowing = post.user.followers.contains(where: { $0.id == user.id })
                
            case .didCommitComment:
                return .run { [state] send in
                    let comment = Comment.Create.Request(text: state.newComment)
                    let response = try await postClient.createComment(comment, state.postId)
                    
                    await send(.didReceiveComments(.success(response)))
                } catch: { error, send in
                    await send(.didReceiveComments(.failure(error)))
                }
                
            case .didReceiveComments(.success(let comments)):
                state.newComment = ""
                state.comments = comments
                
            case .didReceiveImage(.success(let image)):
                state.images.append(image)
                
            case .didTapFollowButton:
                return .run { [state] send in
                    guard let id = state.post?.user.id else { return }
                    if state.isFollowing {
                        try await accountClient.unfollow(id)
                    } else {
                        try await accountClient.follow(id)
                    }
                    
                    await send(.didFinishFollowRequest(.success(())))
                } catch: { error, send in
                    await send(.didFinishFollowRequest(.failure(error)))
                }
                
            case .didFinishFollowRequest(.success):
                state.isFollowing.toggle()
                
            case .didReceivePostDetails(.failure(let error)), 
                    .didReceiveImage(.failure(let error)),
                    .didReceiveComments(.failure(let error)):
                if let error = error as? ZenixError {
                    state.error = error.reason
                }
                
            case .binding, .didFinishFollowRequest:
                break
            }
            
            return .none
        }
    }
}
