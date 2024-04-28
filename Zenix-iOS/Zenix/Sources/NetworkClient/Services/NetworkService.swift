import Dependencies
import Endpoints
import Foundation
import SharedKit

public protocol NetworkServiceProtocol {
    func sendRequest<T>(to endpoint: Endpoint) async throws -> T where T : Decodable
    func sendAndForget(to endpoint: Endpoint) async throws
    func fetchData(at endpoint: Endpoint) async throws -> Data
    func upload(_ data: Data, to endpoint: Endpoint) async throws
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
            throw ZenixError.network(.wrongUrl)
        }
        let response = await session.response(for: request)
        switch response {
        case .success(let success):
            return success.data
        case .failure(let failure):
            throw failure
        }
    }

    public func sendRequest<T>(to endpoint: Endpoint) async throws -> T where T : Decodable {
        guard let request = URLRequest.from(endpoint: endpoint) else {
            throw ZenixError.network(.wrongUrl)
        }
        let response = await session.response(for: request)
        switch response {
        case .success(let success):
            return try JSONDecoder.isoDecoder.decode(T.self, from: success.data)
        case .failure(let failure):
            throw failure
        }
    }

    public func sendAndForget(to endpoint: Endpoint) async throws {
        guard let request = URLRequest.from(endpoint: endpoint) else {
            throw ZenixError.network(.wrongUrl)
        }
        _ = await session.response(for: request)
    }
    
    public func upload(_ data: Data, to endpoint: Endpoint) async throws {
        guard let request = URLRequest.from(endpoint: endpoint) else {
            throw ZenixError.network(.wrongUrl)
        }
        _ = await session.upload(data, for: request)
    }
}

private enum NetworkServiceKey: DependencyKey {
    static let liveValue = NetworkService()
    static var previewValue = NetworkService(session: FakeNetworkSession())
}

public extension DependencyValues {
    var networkService: NetworkService {
        get { self[NetworkServiceKey.self] }
        set { self[NetworkServiceKey.self] = newValue }
    }
}
