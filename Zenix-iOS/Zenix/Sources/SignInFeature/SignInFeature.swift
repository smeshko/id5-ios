import ComposableArchitecture
import Entities
import AccountClient

public struct SignInFeature: Reducer {
    public enum EntryOption: String, Hashable, CaseIterable {
        case signIn, signUp
    }

    public init() {}
    
    public struct State: Equatable {
        @BindingState var entryOption: EntryOption
        @BindingState var email: String
        @BindingState var password: String
        @BindingState var confirmPassword: String
        @BindingState var name: String

        public init(
            entryOption: SignInFeature.EntryOption = .signIn,
            email: String = "",
            password: String = "",
            confirmPassword: String = "",
            name: String = ""
        ) {
            self.entryOption = entryOption
            self.email = email
            self.password = password
            self.confirmPassword = confirmPassword
            self.name = name
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)

        case signInButtonTapped
        case signUpButtonTapped
        case forgotPasswordButtonTapped

        case userInfoReceived(User.Detail.Response, Auth.TokenRefresh.Response)
    }
    
    @Dependency(\.accountClient) var accountClient
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .signInButtonTapped:
                return .run { [state] send in
                    let response = try await accountClient.signIn(.init(email: state.email, password: state.password))
                    await send(.userInfoReceived(response.user, response.token))
                }
            case .signUpButtonTapped:
                guard state.password == state.confirmPassword, !state.password.isEmpty else { break }
                return .run { [state] send in
                    let response = try await accountClient.signUp(
                        .init(
                            email: state.email,
                            password: state.password,
                            fullName: state.name
                        )
                    )
                    await send(.userInfoReceived(response.user, response.token))
                }
            case .forgotPasswordButtonTapped:
                guard !state.email.isEmpty else { break }
                return .run { [state] send in
                    try await accountClient.resetPassword(.init(email: state.email))
                }
            case .userInfoReceived:
                break
            case .binding:
                break
            }
            
            return .none
        }
    }
}
