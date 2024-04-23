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
    
    // metadata
    case metadata(_ attest: Data)
    case challenge
    
    // services
    case nearbyLocations(_ lon: Double, _ lat: Double)
    case addressAutocomplete(_ query: String)
    case geocode(_ id: String)
    
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
        case .resetPassword: "/api/auth/reset-password"
        case .challenge: "/api/metadata/challenge"
        case .metadata: "/api/metadata"
        case .nearbyLocations: "/api/services/places/search"
        case .addressAutocomplete: "/api/services/places/autocomplete"
        case .geocode: "/api/services/places/geocode"
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
        case .signIn, .signUp, .logout, .refresh, .resetPassword, .metadata, .appleAuth: .post
        case .userInfo, .challenge, .nearbyLocations, .addressAutocomplete, .geocode: .get
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
        case .addressAutocomplete(let query):
            return ["query": query]
        case .geocode(let id):
            return ["placeId": id]
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

//      for localhost connection on iPhone run
//      ngrok http 8080 and then paste the address in Debug Settings -> custom
//      https://www.joshwcomeau.com/blog/local-testing-on-an-iphone/
        let isLocalhost = base.contains("localhost")
        
        urlComponents.scheme =
            isLocalhost ? "http" : "https"
        urlComponents.port = 
            isLocalhost ? 8080 : nil
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
