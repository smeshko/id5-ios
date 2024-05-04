import Foundation
import Entities

public extension User.List.Response {
    var fullName: String {
        PersonNameComponents(
            givenName: firstName,
            familyName: lastName
        ).formatted()
    }
}
