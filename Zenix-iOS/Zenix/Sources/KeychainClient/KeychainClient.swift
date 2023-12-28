import Foundation
import SwiftKeychainWrapper
import Dependencies

public struct KeychainClient {
    public enum Key: String {
        case accessToken
        case refreshToken
    }
    public var securelyStoreData: (Data, Key) -> Void
    public var securelyRetrieveData: (Key) -> Data?
    public var securelyStoreString: (String, Key) -> Void
    public var securelyRetrieveString: (Key) -> String?
}

public extension KeychainClient {
    static var live: KeychainClient = {
        let wrapper = KeychainWrapper.standard
        
        return .init(
            securelyStoreData: { data, key in
                wrapper.set(data, forKey: key.rawValue)
            },
            securelyRetrieveData: { key in
                wrapper.data(forKey: key.rawValue)
            },
            securelyStoreString: { string, key in
                wrapper.set(string, forKey: key.rawValue)
            },
            securelyRetrieveString: { key in
                wrapper.string(forKey: key.rawValue)
            }
        )
    }()
}

private enum KeychainClientKey: DependencyKey {
    static let liveValue = KeychainClient.live
}

public extension DependencyValues {
    var keychainClient: KeychainClient {
        get { self[KeychainClientKey.self] }
        set { self[KeychainClientKey.self] = newValue }
    }
}
