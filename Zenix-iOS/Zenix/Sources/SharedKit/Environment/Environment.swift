import Dependencies
import Foundation

public struct Environment {
    public var bundleID: () -> String
    public var stagingHost: String
    public var productionHost: String
    public var teamID: String
}

extension Environment {
    static var live: Environment {
        .init(
            bundleID: {
                if let id = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
                    return id
                }
                fatalError("Couldn't load bundle identifier")
            },
            stagingHost: "oyster-app-d6c9s.ondigitalocean.app",
            productionHost: "",
            teamID: "GR9SJM3FZP"
        )
    }
}

private enum EnvironmentKey: DependencyKey {
    static let liveValue = Environment.live
}

public extension DependencyValues {
    var environment: Environment {
        get { self[EnvironmentKey.self] }
        set { self[EnvironmentKey.self] = newValue }
    }
}
