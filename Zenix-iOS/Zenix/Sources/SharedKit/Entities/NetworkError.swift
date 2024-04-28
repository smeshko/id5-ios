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
    
    var reason: String {
        switch self {
        case .invalidCredentials:
            "Invalid credentials"
        case .invalidRequest:
            "Invalid request"
        case .wrongUrl:
            "Wrong URL"
        case .incorrectResponse:
            "Incorrect Response"
        case .invalidToken:
            "Invalid token"
        case .decodingFailed:
            "Decoding failed"
        case .missingToken:
            "Missing token"
        case .cannotRefreshToken:
            "Failed refreshing token"
        }
    }
}

public struct ErrorResponse: Error, Codable {
    public var error: Bool
    public var reason: String
    public var errorIdentifier: String?
    
    public init(
        error: Bool,
        reason: String,
        errorIdentifier: String? = nil
    ) {
        self.error = error
        self.reason = reason
        self.errorIdentifier = errorIdentifier
    }
}

public enum ZenixError: Error {
    case auth(AuthenticationError)
    case content(ContentError)
    case network(NetworkError)
    case generic(Error)
}

public extension ZenixError {
    var reason: String {
        switch self {
        case .auth(let authenticationError):
            authenticationError.reason
        case .content(let contentError):
            contentError.reason
        case .network(let networkError):
            networkError.reason
        case .generic(let error):
            error.localizedDescription
        }
    }
}
