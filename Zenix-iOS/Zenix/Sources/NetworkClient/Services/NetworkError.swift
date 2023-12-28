import Foundation

public enum NetworkError: Error {
    case invalidCredentials
    case invalidRequest
    case wrongUrl
    case incorrectResponse
    case invalidToken
    case decodingFailed
    case missingToken
}
