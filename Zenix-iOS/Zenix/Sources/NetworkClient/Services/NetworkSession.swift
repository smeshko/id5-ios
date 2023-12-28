import Foundation

protocol NetworkSession: AnyObject {
    func response(for url: URL) async throws -> (Data, URLResponse)
    func response(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {
    func response(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }

    func response(for url: URL) async throws -> (Data, URLResponse) {
        try await response(for: URLRequest(url: url))
    }
}

extension URLResponse {
    var isError: Bool {
        Array(400...599).contains((self as? HTTPURLResponse)?.statusCode ?? 0)
    }
}
