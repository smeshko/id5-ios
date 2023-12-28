import Foundation
import Common

public class AuthorizedNetworkService: NetworkServiceProtocol {

    private let authorizationService: AuthorizationService
    private let session: NetworkSession
    
    private var allowRetry = true

    init(authorizationService: AuthorizationService, session: NetworkSession) {
        self.authorizationService = authorizationService
        self.session = session
    }

    public init() {
        self.authorizationService = AuthorizationService()
        self.session = URLSession.shared
    }

    public func fetchData(at endpoint: Endpoint) async throws -> Data {
        let token = try await authorizationService.validToken()

        guard let request = URLRequest.from(endpoint: endpoint, token: token) else {
            throw NetworkError.wrongUrl
        }
        return try await perform(request).0
    }

    public func sendRequest<T>(to endpoint: Endpoint) async throws -> T where T : Decodable {
        let token = try await authorizationService.validToken()

        guard let request = URLRequest.from(endpoint: endpoint, token: token) else {
            throw NetworkError.wrongUrl
        }
        let response = try await perform(request)
        return try JSONDecoder.isoDecoder.decode(T.self, from: response.0)
    }
    
    public func sendAndForget(to endpoint: Endpoint) async throws {
        let token = try await authorizationService.validToken()

        guard let request = URLRequest.from(endpoint: endpoint, token: token) else {
            throw NetworkError.wrongUrl
        }
        _ = try await perform(request)
    }

    func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        let response = try await session.response(for: request)

        if let httpResponse = response.1 as? HTTPURLResponse, httpResponse.statusCode == 401 {
            if allowRetry {
                _ = try await authorizationService.refreshToken()
                allowRetry = false
                return try await perform(request)
            }

            throw NetworkError.invalidToken
        }
        
        allowRetry = true
        return response
    }
}
