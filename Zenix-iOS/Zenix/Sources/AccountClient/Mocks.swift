import Entities
import Foundation

public extension User.Detail.Response {
    static func mock(
        id: UUID = .init(),
        email: String = "john@doe.com",
        firstName: String = "John",
        lastName: String = "Doe",
        isAdmin: Bool = true,
        isEmailVerified: Bool = true
    ) -> User.Detail.Response {
        .init(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
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
