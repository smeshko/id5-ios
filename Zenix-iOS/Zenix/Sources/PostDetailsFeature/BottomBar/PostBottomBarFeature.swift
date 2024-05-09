import AccountClient
import ComposableArchitecture
import Entities
import PostClient

@Reducer
public struct PostBottomBarFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var isSignedIn: Bool
        var newComment: String
        var commentCount: Int
        let post: Post.Detail.Response

        public init(
            post: Post.Detail.Response,
            isSignedIn: Bool = false,
            newComment: String = "",
            commentCount: Int = 0
        ) {
            self.post = post
            self.isSignedIn = isSignedIn
            self.newComment = newComment
            self.commentCount = commentCount
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case didCommitComment
        
        case binding(BindingAction<State>)
        case didReceiveComments(Result<[Comment.List.Response], Error>)
    }
    
    @Dependency(\.postClient) var postClient
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                break
                
            case .didCommitComment:
                return .run { [state] send in
                    let comment = Comment.Create.Request(text: state.newComment)
                    let response = try await postClient.createComment(comment, state.post.id)
                    
                    await send(.didReceiveComments(.success(response)))
                } catch: { error, send in
                    await send(.didReceiveComments(.failure(error)))
                }

            case .didReceiveComments(.success(let comments)):
                state.commentCount = comments.count
                state.newComment = ""

            case .binding, .didReceiveComments:
                break
            }
            
            return .none
        }
    }
}
