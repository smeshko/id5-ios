import Entities
import Foundation
import SharedKit

struct NetworkResponse {
    let data: Data
    let response: URLResponse
}

protocol NetworkSession: AnyObject {
    func response(for request: URLRequest) async -> Result<NetworkResponse, ZenixError>
    func response(for url: URL) async -> Result<NetworkResponse, ZenixError>
    func upload(_ data: Data, for request: URLRequest) async -> Result<NetworkResponse, ZenixError>
}

extension URLSession: NetworkSession {
    func upload(_ data: Data, for request: URLRequest) async -> Result<NetworkResponse, ZenixError> {
        do {
            let response = try await upload(for: request, from: data)
            if let error = error(from: response.0) {
                return .failure(error)
            } else {
                return .success(
                    .init(
                        data: response.0,
                        response: response.1
                    )
                )
            }
        } catch let error {
            return .failure(.generic(error))
        }
    }
    
    func response(for request: URLRequest) async -> Result<NetworkResponse, ZenixError> {
        do {
            let response = try await data(for: request)
            if let error = error(from: response.0) {
                return .failure(error)
            } else {
                return .success(
                    .init(
                        data: response.0,
                        response: response.1
                    )
                )
            }
        } catch let error {
            return .failure(.generic(error))
        }
    }
    
    func response(for url: URL) async -> Result<NetworkResponse, ZenixError> {
        await response(for: URLRequest(url: url))
    }
    
    private func error(from response: Data) -> ZenixError? {
        if let error = try? JSONDecoder().decode(ErrorResponse.self, from: response) {
            if let id = error.errorIdentifier {
                if let auth = AuthenticationError(rawValue: id) {
                    return .auth(auth)
                } else if let content = ContentError(rawValue: id) {
                    return .content(content)
                }
            } else {
                return .generic(error)
            }
        }
        return nil
    }
}

extension URLResponse {
    var isError: Bool {
        Array(400...599).contains((self as? HTTPURLResponse)?.statusCode ?? 0)
    }
}
