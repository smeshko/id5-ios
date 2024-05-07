import Foundation
import Dependencies

public struct CacheClient {
    public enum Key: String {
        case accountInfo = "user_account_info"
    }

    public var setValue: (Data, String) -> Void
    public var getValue: (String) -> Data?
}

public extension CacheClient {
    static var live: CacheClient = {
        let cache = NSCache<NSString, NSData>()
        
        return .init(
            setValue: { data, key in
                cache.setObject(data as NSData, forKey: key as NSString)
            },
            getValue: { key in
                cache.object(forKey: key as NSString) as? Data
            }
        )
    }()
}

private enum CacheClientKey: DependencyKey {
    static let liveValue = CacheClient.live
}

public extension DependencyValues {
    var cacheClient: CacheClient {
        get { self[CacheClientKey.self] }
        set { self[CacheClientKey.self] = newValue }
    }
}
