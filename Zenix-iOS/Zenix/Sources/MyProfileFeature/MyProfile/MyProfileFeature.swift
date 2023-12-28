import AccountClient
import ComposableArchitecture
import Entities
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
        
        case userInfoReceived(User.Account.Detail.Response)
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
                        await send(.userInfoReceived(userInfo))
                    }
                }
            
            case .signInAction(let action):
                switch action {
                case .tokenReceived(let response):
                    state.signInState = nil
                    state.userDetails = response.user
                default:
                    break
                }
                
            case .userInfoReceived(let response):
                state.userDetails = response
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
        ._printChanges()
    }
}

