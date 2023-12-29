import Foundation
import ComposableArchitecture

public struct SettingsClient {
    public enum Key: String {
        case baseURL
    }
    public var setValue: (Any, Key) -> Void
    public var string: (Key) -> String?
}

public extension SettingsClient {
    static var live: SettingsClient = {
        return .init(
            setValue: { value, key in
                UserDefaults.standard.setValue(value, forKey: key.rawValue)
            },
            string: { key in
                UserDefaults.standard.string(forKey: key.rawValue)
            })
    }()
}

private enum SettingsClientKey: DependencyKey {
    static let liveValue = SettingsClient.live
}

public extension DependencyValues {
    var settingsClient: SettingsClient {
        get { self[SettingsClientKey.self] }
        set { self[SettingsClientKey.self] = newValue }
    }
}
