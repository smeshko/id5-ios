import Foundation

class FakeAuthorizationService: AuthorizationServiceProtocol {
    func refreshToken() async throws -> String {
        "token"
    }
    
    func validToken() async throws -> String {
        "token"
    }
}
