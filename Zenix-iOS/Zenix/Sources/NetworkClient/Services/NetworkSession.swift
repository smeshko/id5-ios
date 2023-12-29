import Foundation
import Entities

struct NetworkResponse {
    let data: Data
    let response: URLResponse
}

protocol NetworkSession: AnyObject {
    func response(for request: URLRequest) async -> Result<NetworkResponse, ZenixError>
    func response(for url: URL) async -> Result<NetworkResponse, ZenixError>
}

extension URLSession: NetworkSession {
    func response(for request: URLRequest) async -> Result<NetworkResponse, ZenixError> {
        do {
            let response = try await data(for: request)
            if let error = try? JSONDecoder().decode(ErrorResponse.self, from: response.0) {
                if let id = error.errorIdentifier {
                    if let auth = AuthenticationError(rawValue: id) {
                        return .failure(.auth(auth))
                    } else if let contest = ContestError(rawValue: id) {
                        return .failure(.contest(contest))
                    }
                } else {
                    return .failure(.generic(error))
                }
            }
            return .success(.init(
                data: response.0,
                response: response.1)
            )
        } catch let error {
            return .failure(.generic(error))
        }
    }
    
    func response(for url: URL) async -> Result<NetworkResponse, ZenixError> {
        await response(for: URLRequest(url: url))
    }
}

extension URLResponse {
    var isError: Bool {
        Array(400...599).contains((self as? HTTPURLResponse)?.statusCode ?? 0)
    }
}
