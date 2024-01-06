import Dependencies
import Endpoints
import Entities
import Foundation
import Helpers
import KeychainClient
import NetworkClient

public struct AccountClient {
    public var isSignedIn: () -> Bool
    public var accountInfo: () async throws -> User.Detail.Response
    public var signIn: (Auth.Login.Request) async throws -> Auth.Login.Response
    public var signUp: (Auth.SignUp.Request) async throws -> Auth.SignUp.Response
    public var resetPassword: (Auth.PasswordReset.Request) async throws -> Void
    public var logout: () async throws -> Void
}

public extension AccountClient {
    static var live: AccountClient = {
        @Dependency(\.authorizedNetworkService) var authService
        @Dependency(\.networkService) var networkService
        @Dependency(\.keychainClient) var keychain
        
        return .init(
            isSignedIn: {
                if let accessToken = keychain.securelyRetrieveString(.accessToken) {
                    do {
                        _ = try JWTDecoder().decode(jwtToken: accessToken)
                        return true
                    } catch {
                        return false
                    }
                }
                return false
            },
            accountInfo: {
                try await authService.sendRequest(to: ZenixEndpoint.userInfo)
            },
            signIn: { request in
                let jsonCreds = try JSONEncoder().encode(request)
                let response: Auth.Login.Response = try await networkService.sendRequest(to: ZenixEndpoint.signIn(jsonCreds))
                keychain.securelyStoreString(response.token.refreshToken, .refreshToken)
                keychain.securelyStoreString(response.token.accessToken, .accessToken)
                
                return response
            },
            signUp: { request in
                let jsonCreds = try JSONEncoder().encode(request)
                let response: Auth.SignUp.Response = try await networkService.sendRequest(to: ZenixEndpoint.signUp(jsonCreds))
                keychain.securelyStoreString(response.token.refreshToken, .refreshToken)
                keychain.securelyStoreString(response.token.accessToken, .accessToken)
                
                return response
            },
            resetPassword: { request in
                let data = try JSONEncoder().encode(request)
                try await networkService.sendAndForget(to: ZenixEndpoint.resetPassword(data))
            },
            logout: {
                try await authService.sendAndForget(to: ZenixEndpoint.logout)
                keychain.delete(.refreshToken)
                keychain.delete(.accessToken)
            }
        )
    }()
}

public extension AccountClient {
    static var preview: AccountClient = {
        .init(
            isSignedIn: { true },
            accountInfo: { .mock() },
            signIn: { _ in .init(token: .mock(), user: .mock()) },
            signUp: { _ in .init(token: .mock(), user: .mock()) },
            resetPassword: { _ in },
            logout: { }
        )
    }()
}

private enum AccountClientKey: DependencyKey {
    static let liveValue = AccountClient.live
    static var previewValue = AccountClient.preview
}

public extension DependencyValues {
    var accountClient: AccountClient {
        get { self[AccountClientKey.self] }
        set { self[AccountClientKey.self] = newValue }
    }
}
