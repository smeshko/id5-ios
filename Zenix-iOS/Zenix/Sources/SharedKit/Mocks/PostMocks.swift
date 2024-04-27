import Entities
import Foundation

public extension Post.List.Response {
    static func mock(
        text: String = "This is a post about a thing",
        createdAt: Date = .now
    ) -> Post.List.Response {
        self.init(
            id: .init(),
            createdAt: createdAt,
            text: text,
            thumbnail: .init(),
            user: User.List.Response(
                id: .init(),
                firstName: "Ivo",
                lastName: "Tsonev",
                email: "test@test.com"
            ),
            commentCount: 5,
            tags: []
        )
    }
}
