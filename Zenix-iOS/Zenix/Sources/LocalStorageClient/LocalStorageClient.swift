import Foundation
import ComposableArchitecture

public struct LocalStorageClient {
    public enum Key: String {
        case baseURL
        case userLocation
        case recentSearches
    }
    
    public var setValue: (Any, Key) -> Void
    public var string: (Key) -> String?
    public var data: (Key) -> Data?
    public var strings: (Key) -> [String]
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
            },
            strings: { key in
                UserDefaults.standard.array(forKey: key.rawValue) as? [String] ?? []
            }
        )
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
