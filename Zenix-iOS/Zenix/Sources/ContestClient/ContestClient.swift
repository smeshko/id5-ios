import Dependencies
import Endpoints
import Entities
import Foundation
import NetworkClient

public struct ContestClient {
    public var allContests: () async throws -> [Contest.List.Response]
}

public extension ContestClient {
    static var live: ContestClient = {
        let service = NetworkService()
        
        return .init(
            allContests: {
                try await service.sendRequest(to: ZenixEndpoint.allContests)
            }
        )
    }()
}

private enum ContestClientKey: DependencyKey {
    static let liveValue = ContestClient.live
}

public extension DependencyValues {
    var contestClient: ContestClient {
        get { self[ContestClientKey.self] }
        set { self[ContestClientKey.self] = newValue }
    }
}
