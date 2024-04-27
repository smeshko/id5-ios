import Foundation
import LocalStorageClient
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

public extension Endpoint {
    var host: String { "localhost" }
    
    var headers: [String : String] {
        ["Content-Type" : "application/json; charset=utf-8"]
    }
    
    var queryParameters: [String : String]? { nil }
    var method: HTTPMethod { .get }
    var body: Data? { nil }
    
    var url: URL? {
        URLBuilder(endpoint: self)
            .components()
            .queryItems()
            .build()
    }
}

/// A helper builder to construct the full URL of a given `Endpoint`.
class URLBuilder {
    @Dependency(\.localStorageClient) var localStorage

    private var endpoint: Endpoint
    private var urlComponents = URLComponents()

    init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }

    /// Sets the basic url components, e.g. host, path, scheme
    func components() -> Self {
        guard let base = localStorage.string(.baseURL) else { return self }

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

    func queryItems() -> Self {
        urlComponents.queryItems = endpoint.queryParameters?
            .map(URLQueryItem.init(name:value:))
        return self
    }

    /// The full url for the requested endpoint.
    func build() -> URL? {
        urlComponents.url
    }
}
