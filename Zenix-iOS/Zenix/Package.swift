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
        .library(name: "StyleGuide", targets: ["StyleGuide"]),

        .library(name: "NetworkClient", targets: ["NetworkClient"]),
        .library(name: "AccountClient", targets: ["AccountClient"]),
        .library(name: "KeychainClient", targets: ["KeychainClient"]),
        .library(name: "LocalStorageClient", targets: ["LocalStorageClient"]),
        .library(name: "AppAttestClient", targets: ["AppAttestClient"]),
        .library(name: "TrackingClient", targets: ["TrackingClient"]),
        .library(name: "LocationClient", targets: ["LocationClient"]),
        .library(name: "PostClient", targets: ["PostClient"]),
        .library(name: "MediaClient", targets: ["MediaClient"]),
        
        .library(name: "SharedKit", targets: ["SharedKit"]),
        .library(name: "SharedViews", targets: ["SharedViews"]),

        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "DiscoverFeature", targets: ["DiscoverFeature"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "SignInFeature", targets: ["SignInFeature"]),
        .library(name: "LocationPickerFeature", targets: ["LocationPickerFeature"]),
        .library(name: "MyProfileFeature", targets: ["MyProfileFeature"]),
        .library(name: "CreatePostFeature", targets: ["CreatePostFeature"]),
        .library(name: "PostDetailsFeature", targets: ["PostDetailsFeature"]),
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
        .target(name: "StyleGuide", dependencies: [entities]),
        .target(name: "Endpoints", dependencies: [tca, "LocalStorageClient"]),
        
        .target(name: "LocalStorageClient", dependencies: [tca]),
        .target(name: "KeychainClient", dependencies: [tca, .product(name: "SwiftKeychainWrapper", package: "SwiftKeychainWrapper")]),
        .target(name: "NetworkClient", dependencies: [entities, tca, "KeychainClient", "Endpoints", "SharedKit"]),
        .target(name: "AccountClient", dependencies: [entities, tca, "NetworkClient", "Endpoints", "SharedKit"]),
        .target(name: "PostClient", dependencies: [entities, tca, "NetworkClient", "Endpoints", "SharedKit"]),
        .target(name: "AppAttestClient", dependencies: [tca, entities, "KeychainClient", "NetworkClient", "Endpoints"]),
        .target(name: "TrackingClient", dependencies: [tca, telemetry]),
        .target(name: "LocationClient", dependencies: [tca, entities, "NetworkClient", "Endpoints"]),
        .target(name: "MediaClient", dependencies: [tca, entities, "NetworkClient", "Endpoints"]),
        
        .target(name: "SharedKit", dependencies: [entities, jwt, tca, "KeychainClient", "TrackingClient"]),
        .target(name: "SharedViews", dependencies: [entities, tca, "StyleGuide", "MediaClient"], resources: [.process("Resources")]),

        .target(name: "AppFeature", dependencies: [tca, "MainNavigationFeature", "TrackingClient", "AppAttestClient", "KeychainClient", "SharedKit"]),
        .target(name: "SettingsFeature", dependencies: [tca, entities, "LocalStorageClient", "SharedKit"]),
        .target(name: "SignInFeature", dependencies: [tca, "AccountClient", "StyleGuide", "SharedKit", "TrackingClient", "LocationClient"]),
        .target(name: "DiscoverFeature", dependencies: [tca, "LocationClient", "NetworkClient", "PostDetailsFeature", "PostClient", "MediaClient", "SharedViews"], resources: [.process("Resources")]),
        .target(name: "LocationPickerFeature", dependencies: [tca, "LocationClient", "NetworkClient"]),
        .target(name: "MyProfileFeature", dependencies: [tca, "StyleGuide", "AccountClient", "SignInFeature"]),
        .target(name: "PostDetailsFeature", dependencies: [tca, entities, "StyleGuide", "Endpoints", "NetworkClient", "SharedKit", "PostClient", "MediaClient"]),
        .target(name: "CreatePostFeature", dependencies: [tca, camera, entities, "StyleGuide", "NetworkClient", "AccountClient", "SignInFeature", "Endpoints", "PostClient", "MediaClient"]),
        .target(name: "MainNavigationFeature", dependencies: [
            tca, "DiscoverFeature", "MyProfileFeature", "SettingsFeature", "CreatePostFeature", "LocationPickerFeature"
        ]),
        
        .testTarget(name: "SignInFeatureTests", dependencies: ["SignInFeature"]),
    ]
)
