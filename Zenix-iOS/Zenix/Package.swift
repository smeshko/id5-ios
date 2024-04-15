// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let tca = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let entities = Target.Dependency.product(name: "Entities", package: "id5-entities")
let jwt = Target.Dependency.product(name: "JWTKit", package: "jwt-kit")
let telemetry = Target.Dependency.product(name: "TelemetryClient", package: "SwiftClient")
let camera = Target.Dependency.product(name: "Capture", package: "Capture")

let package = Package(
    name: "Zenix",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Endpoints", targets: ["Endpoints"]),
        .library(name: "Helpers", targets: ["Helpers"]),
        .library(name: "StyleGuide", targets: ["StyleGuide"]),

        .library(name: "NetworkClient", targets: ["NetworkClient"]),
        .library(name: "AccountClient", targets: ["AccountClient"]),
        .library(name: "KeychainClient", targets: ["KeychainClient"]),
        .library(name: "SettingsClient", targets: ["SettingsClient"]),
        .library(name: "AppAttestClient", targets: ["AppAttestClient"]),
        .library(name: "TrackingClient", targets: ["TrackingClient"]),
        .library(name: "LocationClient", targets: ["LocationClient"]),
        
        .library(name: "SharedKit", targets: ["SharedKit"]),

        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "DiscoverFeature", targets: ["DiscoverFeature"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "SignInFeature", targets: ["SignInFeature"]),
        .library(name: "LocationPickerFeature", targets: ["LocationPickerFeature"]),
        .library(name: "MyProfileFeature", targets: ["MyProfileFeature"]),
        .library(name: "CreatePostFeature", targets: ["CreatePostFeature"]),
        .library(name: "MainNavigationFeature", targets: ["MainNavigationFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(url: "https://github.com/smeshko/id5-entities", branch: "main"),
        .package(url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.1"),
        .package(url: "https://github.com/TelemetryDeck/SwiftClient", from: "1.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0"),
        .package(url: "https://github.com/quentinfasquel/Capture.git", branch: "main")
    ],
    targets: [
        .target(name: "StyleGuide"),
        .target(name: "Helpers", dependencies: [entities, jwt, tca, "KeychainClient"]),
        .target(name: "Endpoints", dependencies: [tca, "SettingsClient"]),
        
        .target(name: "SettingsClient", dependencies: [tca]),
        .target(name: "KeychainClient", dependencies: [tca, .product(name: "SwiftKeychainWrapper", package: "SwiftKeychainWrapper")]),
        .target(name: "NetworkClient", dependencies: [entities, tca, "KeychainClient", "Endpoints", "Helpers"]),
        .target(name: "AccountClient", dependencies: [entities, tca, "NetworkClient", "Endpoints", "Helpers"]),
        .target(name: "AppAttestClient", dependencies: [tca, entities, "KeychainClient", "NetworkClient", "Endpoints"]),
        .target(name: "TrackingClient", dependencies: [tca, telemetry]),
        .target(name: "LocationClient", dependencies: [tca, entities, "NetworkClient", "Endpoints"]),
        
        .target(name: "SharedKit", dependencies: ["TrackingClient", "StyleGuide"]),

        .target(name: "AppFeature", dependencies: [tca, "MainNavigationFeature", "TrackingClient", "AppAttestClient", "KeychainClient"]),
        .target(name: "SettingsFeature", dependencies: [tca, entities, "SettingsClient"]),
        .target(name: "SignInFeature", dependencies: [tca, "AccountClient", "StyleGuide", "SharedKit"]),
        .target(name: "DiscoverFeature", dependencies: [tca, "LocationClient"]),
        .target(name: "LocationPickerFeature", dependencies: [tca, "LocationClient"]),
        .target(name: "MyProfileFeature", dependencies: [tca, "StyleGuide", "AccountClient", "SignInFeature"]),
        .target(name: "CreatePostFeature", dependencies: [tca, camera, entities, "StyleGuide"]),
        .target(name: "MainNavigationFeature", dependencies: [
            tca, "DiscoverFeature", "MyProfileFeature", "SettingsFeature", "CreatePostFeature", "LocationPickerFeature"
        ]),
        
        .testTarget(name: "SignInFeatureTests", dependencies: ["SignInFeature"]),
    ]
)
