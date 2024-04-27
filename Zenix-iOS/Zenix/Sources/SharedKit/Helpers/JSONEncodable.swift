import Foundation

public protocol JSONEncodable: Encodable {
    var encoded: Data { get }
}

public extension Encodable {
    var encoded: Data {
        if let data = try? JSONEncoder().encode(self) {
            return data
        }
        fatalError("Encoding failed")
    }
}
