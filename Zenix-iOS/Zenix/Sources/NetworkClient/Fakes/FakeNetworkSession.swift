import Foundation
import SharedKit

class FakeNetworkSession: NetworkSession {
    func response(for request: URLRequest) async -> Result<NetworkResponse, ZenixError> {
        .success(.init(data: Data(), response: .init()))
    }
    
    func response(for url: URL) async -> Result<NetworkResponse, ZenixError> {
        .success(.init(data: Data(), response: .init()))
    }
    
    func upload(_ data: Data, for request: URLRequest) async -> Result<NetworkResponse, ZenixError> {
        .success(.init(data: Data(), response: .init()))
    }
}
