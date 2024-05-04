import Foundation
import Entities

public extension Post.List.Response {
    var formattedCreatedAt: String {
        createdAt
            .formatted(
                .relative(presentation: .named, unitsStyle: .narrow)
            )
    }
}
