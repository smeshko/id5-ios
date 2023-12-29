import ComposableArchitecture
import Endpoints
import Entities
import Foundation
import Helpers
import KeychainClient

public actor AuthorizationService {
    
    private var refreshTask: Task<String, Error>?
    private let session: NetworkSession
    
    @Dependency(\.keychainClient) var keychain
    
    public init() {
        self.session = URLSession.shared
    }
    
    init(
        session: NetworkSession
    ) {
        self.session = session
    }
    
    public func validToken() async throws -> String {
        if let handle = refreshTask {
            return try await handle.value
        }
        
        guard let storedAccessToken = keychain.securelyRetrieveString(.accessToken),
              let payload = try? JWTDecoder.decode(jwtToken: storedAccessToken) else {
            throw ZenixError.network(.missingToken)
        }
        
        if payload.expiresAt > .now {
            return storedAccessToken
        }
        
        return try await refreshToken()
    }
    
    public func refreshToken() async throws -> String {
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }
        
        let task = Task { () throws -> String in
            defer { refreshTask = nil }
            
            guard let refreshToken = keychain.securelyRetrieveString(.refreshToken) else {
                throw ZenixError.network(.missingToken)
            }
            
            let refreshRequest = User.Token.Refresh.Request(refreshToken: refreshToken)
            let refreshData = try JSONEncoder().encode(refreshRequest)
            let endpoint = ZenixEndpoint.refresh(refreshData)
            guard let request = URLRequest.from(endpoint: endpoint) else { throw ZenixError.network(.invalidRequest) }
            
            let result = await self.session.response(for: request)
            switch result {
            case .success(let success):
                let tokenResponse = try JSONDecoder().decode(User.Token.Refresh.Response.self, from: success.data)
                
                keychain.securelyStoreString(tokenResponse.accessToken, .accessToken)
                keychain.securelyStoreString(tokenResponse.refreshToken, .refreshToken)
                
                return tokenResponse.accessToken
            case .failure(let failure):
                throw failure
            }
        }
        
        self.refreshTask = task
        
        return try await task.value
        
    }
}
