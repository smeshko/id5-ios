import Entities
import Foundation

public extension Post.List.Response {
    static func mock(
        text: String = "This is a post"
    ) -> Post.List.Response {
        self.init(
            id: .init(),
            text: text,
            imageIDs: [],
            videoIDs: [],
            tags: []
        )
    }
}
