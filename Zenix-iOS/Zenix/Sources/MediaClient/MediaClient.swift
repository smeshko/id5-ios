import Dependencies
import Endpoints
import Entities
import Foundation
import NetworkClient
import SharedKit

extension Media.Upload.Request: JSONEncodable {}

public struct MediaClient {
    public var download: (UUID) async throws -> Media.Download.Response
    public var upload: (Media.Upload.Request) async throws -> Media.Upload.Response
}

public extension MediaClient {
    static let live: MediaClient = {
        @Dependency(\.networkService) var networkService
        @Dependency(\.authorizedNetworkService) var authorizedNetworkService

        return .init(
            download: { id in
                try await networkService.sendRequest(to: MediaEndpoint.download(id))
            },
            upload: { request in
                try await authorizedNetworkService.sendRequest(to: MediaEndpoint.upload(request.encoded))
            }
        )
    }()
}

extension MediaClient {
    static let preview: MediaClient = {
        .init(
            download: { _ in
                    .init(data: Data())
            },
            upload: { _ in
                    .init(id: .init(), type: .photo)
            })
    }()
}

private enum MediaClientKey: DependencyKey {
    static let liveValue = MediaClient.live
    static var previewValue = MediaClient.preview
}

public extension DependencyValues {
    var mediaClient: MediaClient {
        get { self[MediaClientKey.self] }
        set { self[MediaClientKey.self] = newValue }
    }
}