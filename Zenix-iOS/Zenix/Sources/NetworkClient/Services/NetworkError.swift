import Foundation
import Entities

public enum NetworkError: Error {
    case invalidCredentials
    case invalidRequest
    case wrongUrl
    case incorrectResponse
    case invalidToken
    case decodingFailed
    case missingToken
    case cannotRefreshToken
}

struct ErrorResponse: Error, Codable {
    var error: Bool
    var reason: String
    var errorIdentifier: String?
}

public enum ZenixError: Error {
    case auth(AuthenticationError)
    case network(NetworkError)
    case generic(Error)
}
