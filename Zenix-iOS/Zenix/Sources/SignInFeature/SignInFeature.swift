import ComposableArchitecture
import Entities
import AccountClient

public struct SignInFeature: Reducer {
    enum EntryOption: String, Hashable, CaseIterable {
        case signIn, signUp
    }

    public init() {}
    
    public struct State: Equatable {
        @BindingState var entryOption: EntryOption = .signUp
        @BindingState var email: String = ""
        @BindingState var password: String = ""
        @BindingState var confirmPassword: String = ""

        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)

        case signInButtonTapped
        case signUpButtonTapped
        case forgotPasswordButtonTapped

        case tokenReceived(User.Auth.Login.Response)
    }
    
    @Dependency(\.accountClient) var accountClient
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .signInButtonTapped:
                return .run { [state] send in
                    let token = try await accountClient.signIn(.init(email: state.email, password: state.password))
                    await send(.tokenReceived(token))
                }
                
            case .signUpButtonTapped:
                break
            case .forgotPasswordButtonTapped:
                break
            case .tokenReceived:
                break
            case .binding:
                break
            }
            
            return .none
        }
    }
}
