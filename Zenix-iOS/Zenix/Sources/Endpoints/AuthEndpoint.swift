import Foundation

public enum AuthEndpoint: Endpoint {
    case signIn(_ credentials: Data)
    case signUp(_ credentials: Data)
    case appleAuth(_ credentials: Data)
    case refresh(_ token: Data)
    case logout
    case resetPassword(_ email: Data)
    
    var base: String { "/api/auth" }

    public var path: String {
        switch self {
        case .signIn: "\(base)/sign-in"
        case .signUp: "\(base)/sign-up"
        case .appleAuth: "\(base)/apple-auth"
        case .logout: "\(base)/logout"
        case .refresh: "\(base)/refresh"
        case .resetPassword: "\(base)/reset-password"
        }
    }
    
    public var method: HTTPMethod { .post }
    
    public var body: Data? {
        switch self {
        case .signIn(let credentials), .signUp(let credentials), .appleAuth(let credentials): credentials
        case .refresh(let token): token
        case .resetPassword(let email): email
        default: nil
        }
    }
}
