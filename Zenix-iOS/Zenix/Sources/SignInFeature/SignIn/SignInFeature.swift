import AccountClient
import AuthenticationServices
import ComposableArchitecture
import Entities
import TrackingClient

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
        
        case onAppear
        case signInButtonTapped
        case signUpButtonTapped
        case forgotPasswordButtonTapped
        case closeButtonTapped
        case doneButtonTapped
        case appleAuthResponseReceived(Result<ASAuthorization, Error>)

        case userInfoReceived(Result<(User.Detail.Response, Auth.TokenRefresh.Response), Error>)
    }
    
    @Dependency(\.accountClient) var accountClient
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.trackingClient) var analytics
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                analytics.send(.view(.auth))
            case .signInButtonTapped:
                state.isLoading = true
                return .run { [state] send in
                    analytics.send(.event(.signInRequested))
                    let response = try await accountClient.signIn(.init(email: state.email, password: state.password))
                    await send(.userInfoReceived(.success((response.user, response.token))))
                } catch: { error, send in
                    analytics.send(.error(.signInFailed))
                    await send(.userInfoReceived(.failure(error)))
                }
                
            case .signUpButtonTapped:
                guard state.password == state.confirmPassword, !state.password.isEmpty else { break }
                state.isLoading = true
                return .run { [state] send in
                    analytics.send(.event(.signUpRequested))
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
                    analytics.send(.error(.signUpFailed))
                    await send(.userInfoReceived(.failure(error)))
                }
                
            case .forgotPasswordButtonTapped:
                analytics.send(.event(.forgotPasswordRequested))
                guard !state.email.isEmpty else { break }
                return .run { [state] send in
                    try await accountClient.resetPassword(.init(email: state.email))
                }
                
            case .appleAuthResponseReceived(let result):
                analytics.send(.event(.appleAuthRequested))
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
                        } catch: { error, send in
                            analytics.send(.error(.appleAuthFailed))
                            await send(.userInfoReceived(.failure(error)))
                        }

                    default:
                        analytics.send(.nonFatal(.appleAuthWrongCredentialReturned))
                    }
                    
                case .failure:
                    analytics.send(.error(.appleAuthFailed))
                }
                
            case .userInfoReceived(let result):
                state.isLoading = false
                
                switch result {
                case .success:
                    analytics.send(.event(.authSuccessful))
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
            }
            
            return .none
        }
    }
}
