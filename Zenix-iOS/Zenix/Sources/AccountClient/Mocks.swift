import Entities
import Foundation

public extension User.Detail.Response {
    static func mock(
        id: UUID = .init(),
        email: String = "john@doe.com",
        fullName: String = "John Doe",
        status: User.Status = .notAccepting,
        level: Int = 0,
        contests: [Contest.Details.Response] = [],
        isAdmin: Bool = true,
        isEmailVerified: Bool = true
    ) -> User.Detail.Response {
        User.Detail.Response(
            id: id,
            email: email,
            fullName: fullName,
            status: status,
            level: level,
            contests: contests,
            isAdmin: isAdmin,
            isEmailVerified: isEmailVerified
        )
    }
}

public extension Auth.TokenRefresh.Response {
    static func mock(
        refreshToken: String = "refresh",
        accessToken: String = "access"
    ) -> Auth.TokenRefresh.Response {
        .init(
            refreshToken: refreshToken,
            accessToken: accessToken
        )
    }
}
