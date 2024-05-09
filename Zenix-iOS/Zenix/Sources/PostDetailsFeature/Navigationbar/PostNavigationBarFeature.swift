import AccountClient
import ComposableArchitecture
import Entities

@Reducer
public struct PostNavigationBarFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        let post: Post.Detail.Response
        var isOwnPost = false
        var isFollowing = false
        var isSignedIn = false
        
        public init(
            post: Post.Detail.Response
        ) {
            self.post = post
        }
    }
    
    public enum Action {
        case onAppear
        case didTapFollowButton
        case didTapUser
        
        case didReceiveUserInfo(Result<User.Detail.Response, Error>)
        case didFinishFollowRequest(Result<Void, Error>)
    }
    
    @Dependency(\.accountClient) var accountClient

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isSignedIn = accountClient.isSignedIn()
                guard state.isSignedIn else { break }
                
                return .run { send in
                    let userInfo = try await accountClient.accountInfo(false)

                    await send(.didReceiveUserInfo(.success(userInfo)))
                } catch: { error, send in
                    await send(.didReceiveUserInfo(.failure(error)))
                }
                
            case .didTapFollowButton:
                return .run { [state] send in
                    let id = state.post.user.id
                    if state.isFollowing {
                        try await accountClient.unfollow(id)
                    } else {
                        try await accountClient.follow(id)
                    }
                    
                    await send(.didFinishFollowRequest(.success(())))
                } catch: { error, send in
                    await send(.didFinishFollowRequest(.failure(error)))
                }

            case .didTapUser:
                break
                
            case .didFinishFollowRequest(.success):
                state.isFollowing.toggle()
                
            case .didReceiveUserInfo(.success(let info)):
                state.isOwnPost = state.post.user.id == info.id
                state.isFollowing = state.post.user.followers.contains { $0.id == info.id }
                
                
            case .didReceiveUserInfo, .didFinishFollowRequest:
                break

            }
            
            return .none
        }
    }
}
