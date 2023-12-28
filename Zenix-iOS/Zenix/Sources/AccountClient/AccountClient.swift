import Dependencies
import Endpoints
import Entities
import Foundation
import Helpers
import KeychainClient
import NetworkClient

public struct AccountClient {
    public var isSignedIn: () -> Bool
    public var accountInfo: () async throws -> User.Account.Detail.Response
    public var signIn: (User.Auth.Login.Request) async throws -> User.Auth.Login.Response
}

public extension AccountClient {
    static var live: AccountClient = {
        let service = NetworkService()
        let authService = AuthorizedNetworkService()
        @Dependency(\.keychainClient) var keychain
        
        return .init(
            isSignedIn: {
                if let accessToken = keychain.securelyRetrieveString(.accessToken) {
                    return (try? JWTDecoder.decode(jwtToken: accessToken).expiresAt > .now) == true
                }
                return false
            },
            accountInfo: {
                try await authService.sendRequest(to: ZenixEndpoint.userInfo)
            },
            signIn: { request in
                let jsonCreds = try  JSONEncoder().encode(request)
                let response: User.Auth.Login.Response = try await service.sendRequest(to: ZenixEndpoint.signIn(jsonCreds))
                
                keychain.securelyStoreString(response.token.refreshToken, .refreshToken)
                keychain.securelyStoreString(response.token.accessToken, .accessToken)
                
                return response
            }
        )
    }()
    
}

private enum AccountClientKey: DependencyKey {
    static let liveValue = AccountClient.live
}

public extension DependencyValues {
    var accountClient: AccountClient {
        get { self[AccountClientKey.self] }
        set { self[AccountClientKey.self] = newValue }
    }
}
