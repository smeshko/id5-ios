import Foundation

public enum UserEndpoint: Endpoint {
    case userInfo
    
    var base: String { "/api/user" }

    public var path: String {
        switch self {
        case .userInfo: "\(base)/me"
        }
    }
}
