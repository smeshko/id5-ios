import AccountClient
import ComposableArchitecture
import Entities
import SharedKit
import SignInFeature

@Reducer
public struct MyProfileFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        @Presents var signInState: SignInFeature.State?
        var userDetails: User.Detail.Response?
        
        public init(
            signInState: SignInFeature.State? = nil, 
            userDetails: User.Detail.Response? = nil
        ) {
            self.signInState = signInState
            self.userDetails = userDetails
        }
    }
    
    public enum Action {
        case signInAction(PresentationAction<SignInFeature.Action>)

        case signInButtonTapped
        case logoutButtonTapped
        case logoutSucceeded
        
        case userInfoReceived(Result<User.Detail.Response, ZenixError>)
        case onAppear
    }
    
    @Dependency(\.accountClient) private var accountClient
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if accountClient.isSignedIn() {
                    return .run { send in
                        let userInfo = try await accountClient.accountInfo()
                        await send(.userInfoReceived(.success(userInfo)))
                    }
                    catch: { error, send in
                        if let error = error as? ZenixError {
                            await send(.userInfoReceived(.failure(error)))
                        }
                    }
                }
            
            case .signInAction(let action):
                switch action {
                case .presented(.userInfoReceived(.success(let user))):
                    state.userDetails = user.0
                default:
                    break
                }
                
            case .userInfoReceived(let response):
                switch response {
                case .success(let details):
                    state.userDetails = details
                case .failure:
                    state.signInState = .init()
                }
                
            case .logoutButtonTapped:
                return .run { send in
                    try await accountClient.logout()
                    await send(.logoutSucceeded)
                }
                
            case .signInButtonTapped:
                state.signInState = .init()
                
            case .logoutSucceeded:
                state.userDetails = nil
            }
            
            return .none
        }
        .ifLet(\.$signInState, action: \.signInAction) {
            SignInFeature()
        }
    }
}

