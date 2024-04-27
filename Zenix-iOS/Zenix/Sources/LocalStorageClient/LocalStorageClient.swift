import Foundation
import ComposableArchitecture

public struct LocalStorageClient {
    public enum Key: String {
        case baseURL
        case userLocation
    }
    
    public var setValue: (Any, Key) -> Void
    public var string: (Key) -> String?
    public var data: (Key) -> Data?
}

public extension LocalStorageClient {
    static var live: LocalStorageClient = {
        return .init(
            setValue: { value, key in
                UserDefaults.standard.setValue(value, forKey: key.rawValue)
            },
            string: { key in
                UserDefaults.standard.string(forKey: key.rawValue)
            },
            data: { key in
                UserDefaults.standard.value(forKey: key.rawValue) as? Data
            })
    }()
}

private enum LocalStorageClientKey: DependencyKey {
    static let liveValue = LocalStorageClient.live
}

public extension DependencyValues {
    var localStorageClient: LocalStorageClient {
        get { self[LocalStorageClientKey.self] }
        set { self[LocalStorageClientKey.self] = newValue }
    }
}
