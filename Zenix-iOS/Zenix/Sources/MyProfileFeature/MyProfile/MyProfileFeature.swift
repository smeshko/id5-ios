import AccountClient
import ComposableArchitecture
import Entities
import NetworkClient
import SignInFeature

public struct MyProfileFeature: Reducer {
    enum EntryOption: String, Hashable, CaseIterable {
        case signIn, signUp
    }
    
    public init() {}
    
    public struct State: Equatable {
        var signInState: SignInFeature.State?
        var userDetails: User.Account.Detail.Response?
        
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case signInAction(SignInFeature.Action)
        case logoutButtonTapped
        case logoutSucceeded
        
        case userInfoReceived(Result<User.Account.Detail.Response, ZenixError>)
        case onAppear
    }
    
    @Dependency(\.accountClient) private var accountClient
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if !accountClient.isSignedIn() {
                    state.signInState = .init()
                } else {
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
                case .userInfoReceived(let user, _):
                    state.signInState = nil
                    state.userDetails = user
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
                
            case .logoutSucceeded:
                state.signInState = .init()
                
            case .binding:
                break
            }
            
            return .none
        }
        .ifLet(
            \.signInState,
             action: /Action.signInAction
        ) {
            SignInFeature()
        }
    }
}

