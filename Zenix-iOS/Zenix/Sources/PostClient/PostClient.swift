import Dependencies
import Endpoints
import Entities
import Foundation
import NetworkClient
import SharedKit

extension Post.Create.Request: JSONEncodable {}
extension Comment.Create.Request: JSONEncodable {}

public struct PostClient {
    public var all: () async throws -> [Post.List.Response]
    public var details: (UUID) async throws -> Post.Detail.Response
    public var create: (Post.Create.Request) async throws -> Post.Create.Response
    
    public var createComment: (Comment.Create.Request, UUID) async throws -> [Comment.List.Response]
    public var commentsForPost: (UUID) async throws -> [Comment.List.Response]
}

public extension PostClient {
    static let live: PostClient = {
        @Dependency(\.networkService) var networkService
        @Dependency(\.authorizedNetworkService) var authorizedNetworkService
        
        return .init(
            all: {
                try await networkService.sendRequest(to: PostEndpoint.allPosts)
            },
            details: { id in
                try await networkService.sendRequest(to: PostEndpoint.postDetails(id))
            },
            create: { request in
                try await networkService.sendRequest(to: PostEndpoint.createPost(request.encoded))
            },
            createComment: { request, postId in
                try await authorizedNetworkService.sendRequest(to: PostEndpoint.createComment(request.encoded, postId))
            },
            commentsForPost: { id in
                try await networkService.sendRequest(to: PostEndpoint.commentsForPost(id))
            }
        )
    }()
}

extension PostClient {
    static let preview: PostClient = {
        return .init(
            all: {
                [
                    .mock(text: "This is post #\(Int.random(in: 0...100))"),
                    .mock(text: "This is post #\(Int.random(in: 0...100))"),
                    .mock(text: "This is post #\(Int.random(in: 0...100))"),
                    .mock(text: "This is post #\(Int.random(in: 0...100))"),
                    .mock(text: "This is post #\(Int.random(in: 0...100))"),
                    .mock(text: "This is post #\(Int.random(in: 0...100))"),
                    .mock(text: "This is post #\(Int.random(in: 0...100))"),
                    .mock(text: "This is post #\(Int.random(in: 0...100))")
                ]
            },
            details: { _ in
                    .init(
                        id: .init(),
                        title: "Title",
                        createdAt: .now,
                        user: .mock(),
                        comments: [],
                        text: "This is a post",
                        likes: 4,
                        imageIDs: [],
                        videoIDs: [],
                        tags: []
                    )
            },
            create: { _ in
                    .init(id: .init(), title: "Title", createdAt: .now, text: "A post", imageIDs: [], videoIDs: [])
            },
            createComment: { _, _ in
                [
                    .init(id: .init(), createdAt: .now, text: "A comment", postID: .init(), user: .init(id: .init(), email: "ivo@ivo.com"))
                ]
            },
            commentsForPost: { _ in
                []
            })
    }()
}

private enum PostClientKey: DependencyKey {
    static let liveValue = PostClient.live
    static var previewValue = PostClient.preview
}

public extension DependencyValues {
    var postClient: PostClient {
        get { self[PostClientKey.self] }
        set { self[PostClientKey.self] = newValue }
    }
}
