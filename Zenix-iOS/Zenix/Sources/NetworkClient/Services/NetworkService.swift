import Foundation
import Common

public protocol NetworkServiceProtocol {
    func sendRequest<T>(to endpoint: Endpoint) async throws -> T where T : Decodable
    func sendAndForget(to endpoint: Endpoint) async throws
    func fetchData(at endpoint: Endpoint) async throws -> Data
}

public struct NetworkService: NetworkServiceProtocol {

    private let session: NetworkSession

    public init() {
        self.session = URLSession.shared
    }

    init(session: NetworkSession) {
        self.session = session
    }

    public func fetchData(at endpoint: Endpoint) async throws -> Data {
        guard let request = URLRequest.from(endpoint: endpoint) else {
            throw NetworkError.wrongUrl
        }
        return try await session.response(for: request).0
    }

    public func sendRequest<T>(to endpoint: Endpoint) async throws -> T where T : Decodable {
        guard let request = URLRequest.from(endpoint: endpoint) else {
            throw NetworkError.wrongUrl
        }
        let (data, _) = try await session.response(for: request)
        return try JSONDecoder.isoDecoder.decode(T.self, from: data)
    }

    public func sendAndForget(to endpoint: Endpoint) async throws {
        guard let request = URLRequest.from(endpoint: endpoint) else {
            throw NetworkError.wrongUrl
        }
        _ = try await session.response(for: request)
    }
}
