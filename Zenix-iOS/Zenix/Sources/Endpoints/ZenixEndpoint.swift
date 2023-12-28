import Foundation
import Common

public enum ZenixEndpoint: Endpoint {
    // auth
    case signIn(_ credentials: Data)
    case refresh(_ token: Data)
    case logout
    
    // account
    case userInfo
    
    // contests
    case allContests
    
    public var host: String {
//        "zenix-staging.fly.dev"
        "localhost"
    }
    
    public var path: String {
        switch self {
        case .signIn: "/api/auth/sign-in"
        case .logout: "/api/auth/logout"
        case .refresh: "/api/auth/refresh"
        case .userInfo: "/api/user/me"
        case .allContests: "/api/contest/list"
        }
    }
    
    public var url: URL? {
        URLBuilder2(endpoint: self)
            .components()
            .queryItems()
            .build()
    }
    
    public var method: HTTPMethod {
        switch self {
        case .signIn, .logout, .refresh: .post
        case .userInfo, .allContests: .get
        }
    }
    
    public var body: Data? {
        switch self {
        case .signIn(let credentials): credentials
        case .refresh(let token): token
        default: nil
        }
    }

    public var headers: [String : String] {
        ["Content-Type" : "application/json; charset=utf-8"]
    }
    
    public var queryParameters: [String : String]? { [:]}

}

/// A helper builder to construct the full URL of a given `Endpoint`.
public class URLBuilder2 {
    private var endpoint: Endpoint
    private var urlComponents = URLComponents()

    public init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }

    /// Sets the basic url components, e.g. host, path, scheme
    public func components() -> Self {
        urlComponents.scheme = "http"
        urlComponents.port = 8080
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path

        return self
    }

    public func queryItems() -> Self {
        urlComponents.queryItems = endpoint.queryParameters?
            .map(URLQueryItem.init(name:value:))
        return self
    }

    /// The full url for the requested endpoint.
    public func build() -> URL? {
        urlComponents.url
    }
}
