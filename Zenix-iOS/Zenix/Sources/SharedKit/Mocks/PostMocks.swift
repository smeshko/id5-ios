import Entities
import Foundation

public extension Post.List.Response {
    static func mock(
        text: String = "This is a post about a thing",
        createdAt: Date = .now
    ) -> Post.List.Response {
        self.init(
            id: .init(),
            title: "This is a short title",
            createdAt: createdAt,
            text: text,
            thumbnail: .init(),
            user: User.List.Response(
                id: .init(),
                firstName: "Ivo",
                lastName: "Tsonev",
                email: "test@test.com"
            ), 
            likes: 2,
            commentCount: 5,
            tags: []
        )
    }
}

public extension Post.Detail.Response {
    static func mock(
        text: String = "This is a post about a thing",
        createdAt: Date = .now,
        comments: [Comment.List.Response] = []
    ) -> Post.Detail.Response {
        self.init(
            id: .init(),
            title: "This is short title",
            createdAt: createdAt,
            user: .mock(),
            comments: comments,
            text: text,
            likes: 5,
            imageIDs: [],
            videoIDs: [],
            tags: []
        )
    }
}
