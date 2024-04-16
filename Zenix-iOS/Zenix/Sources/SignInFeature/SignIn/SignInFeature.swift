import ComposableArchitecture
import Entities
import AccountClient
import AuthenticationServices

@Reducer
public struct SignInFeature {
    public enum EntryOption: String, Hashable, CaseIterable {
        case signIn, signUp
        
        var title: String {
            switch self {
            case .signIn: "Sign In"
            case .signUp: "Sign Up"
            }
        }
    }
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var entryOption: EntryOption
        var email: String
        var password: String
        var confirmPassword: String
        var firstName: String
        var lastName: String
        var isLoading: Bool
        var isFormValid: Bool
        var signInSuccessful: Bool
//        var path = StackState<Path.State>()
        
        public init(
            entryOption: SignInFeature.EntryOption = .signIn,
            email: String = "",
            password: String = "",
            confirmPassword: String = "",
            firstName: String = "",
            lastName: String = "",
            isLoading: Bool = false,
            isFormValid: Bool = false,
            signInSuccessful: Bool = false
        ) {
            self.entryOption = entryOption
            self.email = email
            self.password = password
            self.confirmPassword = confirmPassword
            self.firstName = firstName
            self.lastName = lastName
            self.isLoading = isLoading
            self.isFormValid = isFormValid
            self.signInSuccessful = signInSuccessful
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case signInButtonTapped
        case signUpButtonTapped
        case forgotPasswordButtonTapped
        case closeButtonTapped
        case doneButtonTapped
        case appleAuthResponseReceived(Result<ASAuthorization, Error>)
//        case path(StackAction<Path.State, Path.Action>)
        
        case userInfoReceived(Result<(User.Detail.Response, Auth.TokenRefresh.Response), Error>)
    }
    
    @Dependency(\.accountClient) var accountClient
    @Dependency(\.dismiss) var dismiss
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .signInButtonTapped:
                state.isLoading = true
                return .run { [state] send in
                    let response = try await accountClient.signIn(.init(email: state.email, password: state.password))
                    await send(.userInfoReceived(.success((response.user, response.token))))
                } catch: { error, send in
                    await send(.userInfoReceived(.failure(error)))
                }
                
            case .signUpButtonTapped:
                guard state.password == state.confirmPassword, !state.password.isEmpty else { break }
                state.isLoading = true
                return .run { [state] send in
                    let response = try await accountClient.signUp(
                        .init(
                            email: state.email,
                            password: state.password,
                            location: .init(address: "", city: "", zipcode: "", longitude: 0, latitude: 0, radius: 0),
                            firstName: state.firstName,
                            lastName: state.lastName
                        )
                    )
                    await send(.userInfoReceived(.success((response.user, response.token))))
                } catch: { error, send in
                    await send(.userInfoReceived(.failure(error)))
                }
                
            case .forgotPasswordButtonTapped:
                guard !state.email.isEmpty else { break }
                return .run { [state] send in
                    try await accountClient.resetPassword(.init(email: state.email))
                }
                
            case .appleAuthResponseReceived(let result):
                switch result {
                case .success(let auth):
                    
                    switch auth.credential {
                    case let appleIDCredential as ASAuthorizationAppleIDCredential:
                        guard let token = appleIDCredential.identityToken,
                              let string = String(data: token, encoding: .utf8) else {
                            break
                        }
                        let request = Auth.Apple.Request(appleIdentityToken: string)
                        return .run { send in
                            let response = try await accountClient.appleAuth(request)
                            
                            await send(.userInfoReceived(.success((response.user, response.token))))
                        }

                    default:
                        break
                    }
                    
                    
                    print(auth)
                    
                    
                case .failure:
                    print("error")
                }
                
            case .userInfoReceived(let result):
                state.isLoading = false
                
                switch result {
                case .success:
                    state.signInSuccessful = true
                    return .run { _ in
                        await dismiss()
                    }
                case .failure:
                    break
                }
                
            case .binding:
                switch state.entryOption {
                case .signIn:
                    state.isFormValid = (!state.email.isEmpty && state.password.count >= 8)
                case .signUp:
                    state.isFormValid = (!state.email.isEmpty &&
                                         state.password.count >= 8 &&
                                         state.password == state.confirmPassword)
                    
                }
            
            case .closeButtonTapped, .doneButtonTapped:
                return .run { _ in
                    await dismiss()
                }
                
//            case .path:
//                break
            }
            
            return .none
        }
//        .forEach(\.path, action: \.path) {
//            Path()
//        }
    }
}

//public extension SignInFeature {
//    
//    @Reducer
//    struct Path {
//        @ObservableState
//        public enum State: Equatable {
//            case verification(VerificationMailFeature.State)
//        }
//        
//        public enum Action {
//            case verification(VerificationMailFeature.Action)
//        }
//        
//        public var body: some ReducerOf<Self> {
//            Scope(state: \.verification, action: \.verification) {
//                VerificationMailFeature()
//            }
//        }
//    }
//}
