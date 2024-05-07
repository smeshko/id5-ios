import Foundation

public extension Encodable {
    var jsonEncoded: Data {
        if let data = try? JSONEncoder().encode(self) {
            return data
        }
        fatalError("Encoding failed")
    }
}
