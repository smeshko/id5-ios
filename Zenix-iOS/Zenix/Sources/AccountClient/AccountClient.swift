import Dependencies
import Endpoints
import Entities
import Foundation
import KeychainClient
import NetworkClient
import LocalStorageClient
import SharedKit

public struct AccountClient {
    public var isSignedIn: () -> Bool
    public var accountInfo: (Bool) async throws -> User.Detail.Response
    public var signIn: (Auth.Login.Request) async throws -> Auth.Login.Response
    public var signUp: (Auth.SignUp.Request) async throws -> Auth.SignUp.Response
    public var appleAuth: (Auth.Apple.Request) async throws -> Auth.Apple.Response
    public var resetPassword: (Auth.PasswordReset.Request) async throws -> Void
    public var follow: (UUID) async throws -> Void
    public var unfollow: (UUID) async throws -> Void
    public var logout: () async throws -> Void
}

public extension AccountClient {
    static var live: AccountClient = {
        @Dependency(\.authorizedNetworkService) var authService
        @Dependency(\.networkService) var networkService
        @Dependency(\.keychainClient) var keychain
        @Dependency(\.cacheClient) var cache
        
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
            accountInfo: { forceUpdate in
                if forceUpdate {
                    let response: User.Detail.Response = try await authService.sendRequest(to: UserEndpoint.userInfo)
                    cache.setValue(response.jsonEncoded, CacheClient.Key.accountInfo.rawValue)
                    return response
                }
                
                if let cached = cache.getValue(CacheClient.Key.accountInfo.rawValue) {
                    let response = try JSONDecoder().decode(User.Detail.Response.self, from: cached)
                    return response
                }
                
                let response: User.Detail.Response = try await authService.sendRequest(to: UserEndpoint.userInfo)
                cache.setValue(response.jsonEncoded, CacheClient.Key.accountInfo.rawValue)
                return response
            },
            signIn: { request in
                let response: Auth.Login.Response = try await networkService.sendRequest(to: AuthEndpoint.signIn(request.jsonEncoded))
                keychain.securelyStoreString(response.token.refreshToken, .refreshToken)
                keychain.securelyStoreString(response.token.accessToken, .accessToken)
                
                return response
            },
            signUp: { request in
                let response: Auth.SignUp.Response = try await networkService.sendRequest(to: AuthEndpoint.signUp(request.jsonEncoded))
                keychain.securelyStoreString(response.token.refreshToken, .refreshToken)
                keychain.securelyStoreString(response.token.accessToken, .accessToken)
                
                return response
            },
            appleAuth: { request in
                try await networkService.sendRequest(to: AuthEndpoint.appleAuth(request.jsonEncoded))
            },
            resetPassword: { request in
                try await networkService.sendAndForget(to: AuthEndpoint.resetPassword(request.jsonEncoded))
            },
            follow: { id in
                try await authService.sendAndForget(to: UserEndpoint.follow(id))
            },
            unfollow: { id in
                try await authService.sendAndForget(to: UserEndpoint.unfollow(id))
            },
            logout: {
                try await authService.sendAndForget(to: AuthEndpoint.logout)
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
            accountInfo: { _ in .mock() },
            signIn: { _ in .init(token: .mock(), user: .mock()) },
            signUp: { _ in .init(token: .mock(), user: .mock()) },
            appleAuth: { _ in .init(token: .mock(), user: .mock()) },
            resetPassword: { _ in },
            follow: { _ in },
            unfollow: { _ in },
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
