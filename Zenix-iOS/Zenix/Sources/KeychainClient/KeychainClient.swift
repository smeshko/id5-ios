import Foundation
import SwiftKeychainWrapper
import Dependencies

public struct KeychainClient {
    public enum Key: String {
        case accessToken
        case refreshToken
        case attestKeyId
        case jwtKey
    }
    
    public var securelyStoreData: (Data, Key) -> Void
    public var securelyRetrieveData: (Key) -> Data?
    public var securelyStoreString: (String, Key) -> Void
    public var securelyRetrieveString: (Key) -> String?
    public var delete: (Key) -> Void
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
            },
            delete: { key in
                wrapper.removeObject(forKey: key.rawValue)
            }
        )
    }()
}

public extension KeychainClient {
    static var preview: KeychainClient = {
        .init(
            securelyStoreData: { _, key in
                print("keychain saved data at \(key)")
            },
            securelyRetrieveData: { key in
                print("keychain retrieved data at \(key)")
                return Data()
            },
            securelyStoreString: { _, key in
                print("keychain saved string at \(key)")
            },
            securelyRetrieveString: { key in
                print("keychain received string at \(key)")
                return ""
            },
            delete: { key in
                print("keychain deleted data at \(key)")
            })
    }()
}

private enum KeychainClientKey: DependencyKey {
    static let liveValue = KeychainClient.live
    static var previewValue = KeychainClient.preview
}

public extension DependencyValues {
    var keychainClient: KeychainClient {
        get { self[KeychainClientKey.self] }
        set { self[KeychainClientKey.self] = newValue }
    }
}
