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
        var imageIDs: [UUID] = []
        var error: String?
        
        var navigationBarState: PostNavigationBarFeature.State?
        var bottomBarState: PostBottomBarFeature.State?
        
        public init(
            postId: UUID
        ) {
            self.postId = postId
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        
        case navigationBarAction(PostNavigationBarFeature.Action)
        case bottomBarAction(PostBottomBarFeature.Action)
        
        case binding(BindingAction<State>)
        case didReceivePostDetails(Result<Post.Detail.Response, Error>)
        case didReceiveImage(Result<Media.Download.Response, Error>)
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

                    await send(.didReceivePostDetails(.success(response)))
                } catch: { error, send in
                    await send(.didReceivePostDetails(.failure(error)))
                }
                
            case .didReceivePostDetails(.success(let post)):
                state.navigationBarState = .init(post: post)
                state.bottomBarState = .init(post: post, isSignedIn: state.isSignedIn, commentCount: post.comments.count)
                state.post = post
                state.comments = post.comments
                state.imageIDs = post.imageIDs
                
            case .bottomBarAction(.didReceiveComments(.success(let comments))):
                state.comments = comments
                
            case .didReceiveImage(.success(let image)):
                state.images.append(image)

            case .didReceivePostDetails(.failure(let error)), 
                    .didReceiveImage(.failure(let error)),
                    .bottomBarAction(.didReceiveComments(.failure(let error))),
                    .navigationBarAction(.didReceiveUserInfo(.failure(let error))):
                if let error = error as? ZenixError {
                    state.error = error.reason
                }
                
            case .navigationBarAction, .bottomBarAction:
                break
                
            case .binding:
                break
            }
            
            return .none
        }
        .ifLet(\.navigationBarState, action: \.navigationBarAction) {
            PostNavigationBarFeature()
        }
        .ifLet(\.bottomBarState, action: \.bottomBarAction) {
            PostBottomBarFeature()
        }
    }
}
