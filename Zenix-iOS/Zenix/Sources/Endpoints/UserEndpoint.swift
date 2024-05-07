import Foundation

public enum UserEndpoint: Endpoint {
    case userInfo
    case follow(UUID)
    case unfollow(UUID)
    
    var base: String { "/api/user" }

    public var path: String {
        switch self {
        case .userInfo: "\(base)/me"
        case .follow(let id): "\(base)/follow/\(id)"
        case .unfollow(let id): "\(base)/unfollow/\(id)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .userInfo: .get
        case .follow, .unfollow: .post
        }
    }
}
