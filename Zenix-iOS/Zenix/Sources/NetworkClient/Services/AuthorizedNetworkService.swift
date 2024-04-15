import Endpoints
import Dependencies
import Foundation

public class AuthorizedNetworkService: NetworkServiceProtocol {

    private let authorizationService: AuthorizationServiceProtocol
    private let session: NetworkSession
    
    private var allowRetry = true

    init(
        authorizationService: AuthorizationServiceProtocol,
        session: NetworkSession
    ) {
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
            throw ZenixError.network(.wrongUrl)
        }
        return try await perform(request).0
    }

    public func sendRequest<T>(to endpoint: Endpoint) async throws -> T where T : Decodable {
        let token = try await authorizationService.validToken()

        guard let request = URLRequest.from(endpoint: endpoint, token: token) else {
            throw ZenixError.network(.wrongUrl)
        }
        let response = try await perform(request)
        return try JSONDecoder.isoDecoder.decode(T.self, from: response.0)
    }
    
    public func sendAndForget(to endpoint: Endpoint) async throws {
        let token = try await authorizationService.validToken()

        guard let request = URLRequest.from(endpoint: endpoint, token: token) else {
            throw ZenixError.network(.wrongUrl)
        }
        _ = try await perform(request)
    }
    
    public func upload(_ data: Data, to endpoint: Endpoint) async throws {
        fatalError("Upload not supported in auth service")
    }

    func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        let response = await session.response(for: request)
        
        switch response {
        case .success(let success):
            return (success.data, success.response)
        case .failure(let failure):
            switch failure {
            case .auth(.refreshTokenHasExpired), 
                    .auth(.refreshTokenOrUserNotFound),
                    .auth(.accessTokenHasExpired):
                _ = try await authorizationService.refreshToken()
                return try await perform(request)
            default:
                throw failure
            }
        }
    }
}

private enum AuthorizedNetworkServiceKey: DependencyKey {
    static let liveValue = AuthorizedNetworkService()
    static var previewValue = AuthorizedNetworkService(
        authorizationService: FakeAuthorizationService(),
        session: FakeNetworkSession()
    )
}

public extension DependencyValues {
    var authorizedNetworkService: AuthorizedNetworkService {
        get { self[AuthorizedNetworkServiceKey.self] }
        set { self[AuthorizedNetworkServiceKey.self] = newValue }
    }
}
