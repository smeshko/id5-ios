import Foundation
import SettingsClient
import ComposableArchitecture

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

/// An object that represents an API endpoint. Contains all properties needed to build a request to an endpoint.
public protocol Endpoint {
    var host: String { get }
    var path: String { get }
    var url: URL? { get }
    var method: HTTPMethod { get }
    var body: Data? { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String]? { get }
}

public enum ZenixEndpoint: Endpoint {
    
    // auth
    case signIn(_ credentials: Data)
    case signUp(_ credentials: Data)
    case appleAuth(_ credentials: Data)
    case refresh(_ token: Data)
    case logout
    case resetPassword(_ email: Data)
    
    // account
    case userInfo
    
    // contests
    case allContests
    
    // metadata
    case metadata(_ attest: Data)
    case challenge
    case nearbyLocations(_ lon: Double, _ lat: Double)
    
    public var host: String {
        "localhost"
    }
    
    public var path: String {
        switch self {
        case .signIn: "/api/auth/sign-in"
        case .signUp: "/api/auth/sign-up"
        case .appleAuth: "/api/auth/apple-auth"
        case .logout: "/api/auth/logout"
        case .refresh: "/api/auth/refresh"
        case .userInfo: "/api/user/me"
        case .allContests: "/api/contest/list"
        case .resetPassword: "/api/auth/reset-password"
        case .challenge: "/api/metadata/challenge"
        case .metadata: "/api/metadata"
        case .nearbyLocations: "/api/metadata/nearby-locations"
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
        case .signIn, .signUp, .logout, .refresh, .resetPassword: .post
        case .metadata, .appleAuth: .post
        case .userInfo, .allContests, .challenge, .nearbyLocations: .get
        }
    }
    
    public var body: Data? {
        switch self {
        case .signIn(let credentials), .signUp(let credentials), .appleAuth(let credentials): credentials
        case .refresh(let token): token
        case .resetPassword(let email): email
        case .metadata(let attest): attest
        default: nil
        }
    }

    public var headers: [String : String] {
        ["Content-Type" : "application/json; charset=utf-8"]
    }
    
    public var queryParameters: [String : String]? {
        switch self {
        case .nearbyLocations(let lon, let lat):
            return ["latitude": "\(lat)", "longitude": "\(lon)"]
        default:
            return [:]
        }
    }
}

/// A helper builder to construct the full URL of a given `Endpoint`.
public class URLBuilder2 {
    @Dependency(\.settingsClient) var settings

    private var endpoint: Endpoint
    private var urlComponents = URLComponents()

    public init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }

    /// Sets the basic url components, e.g. host, path, scheme
    public func components() -> Self {
        guard let base = settings.string(.baseURL) else { return self }
        let isLocalhost = base.contains("localhost")
        
        urlComponents.scheme =
            isLocalhost ? "http" : "https"
        urlComponents.port = 
            isLocalhost ? 8080 : nil
//        if iPhone
//    https://www.joshwcomeau.com/blog/local-testing-on-an-iphone/
//        ngrok http 8080
//        urlComponents.scheme = "https"
//        urlComponents.host = "6bc2-176-12-62-75.ngrok-free.app"
//        else
        urlComponents.host = base
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
