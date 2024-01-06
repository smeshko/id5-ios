// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let tca = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let entities = Target.Dependency.product(name: "Entities", package: "entities")
let common = Target.Dependency.product(name: "Common", package: "common")
let jwt = Target.Dependency.product(name: "JWTKit", package: "jwt-kit")

let package = Package(
    name: "Zenix",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Endpoints", targets: ["Endpoints"]),
        .library(name: "Helpers", targets: ["Helpers"]),
        .library(name: "StyleGuide", targets: ["StyleGuide"]),

        .library(name: "NetworkClient", targets: ["NetworkClient"]),
        .library(name: "AccountClient", targets: ["AccountClient"]),
        .library(name: "ContestClient", targets: ["ContestClient"]),
        .library(name: "KeychainClient", targets: ["KeychainClient"]),
        .library(name: "SettingsClient", targets: ["SettingsClient"]),
        .library(name: "AppAttestClient", targets: ["AppAttestClient"]),
        .library(name: "TrackingClient", targets: ["TrackingClient"]),
        
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "DiscoverFeature", targets: ["DiscoverFeature"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "SignInFeature", targets: ["SignInFeature"]),
        .library(name: "MyProfileFeature", targets: ["MyProfileFeature"]),
        .library(name: "MainNavigationFeature", targets: ["MainNavigationFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(url: "https://github.com/zenix-invest/common", from: "0.1.0"),
        .package(url: "https://github.com/zenix-invest/entities", from: "0.1.0"),
        .package(url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.1"),
        .package(url: "https://github.com/TelemetryDeck/SwiftClient", from: "1.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0")
    ],
    targets: [
        .target(name: "StyleGuide"),
        .target(name: "Helpers", dependencies: [entities, jwt, tca, "KeychainClient"]),
        .target(name: "Endpoints", dependencies: [tca, common, "SettingsClient"]),
        
        .target(name: "SettingsClient", dependencies: [tca]),
        .target(name: "KeychainClient", dependencies: [tca, .product(name: "SwiftKeychainWrapper", package: "SwiftKeychainWrapper")]),
        .target(name: "NetworkClient", dependencies: [entities, tca, "KeychainClient", "Endpoints", "Helpers"]),
        .target(name: "AccountClient", dependencies: [entities, common, tca, "NetworkClient", "Endpoints", "Helpers"]),
        .target(name: "ContestClient", dependencies: [entities, common, tca, "NetworkClient", "Endpoints"]),
        .target(name: "AppAttestClient", dependencies: [tca, entities, "KeychainClient", "NetworkClient", "Endpoints"]),
        .target(name: "TrackingClient", dependencies: [tca, .product(name: "TelemetryClient", package: "SwiftClient")]),

        .target(name: "AppFeature", dependencies: [tca, "MainNavigationFeature", "TrackingClient", "AppAttestClient", "KeychainClient"]),
        .target(name: "SettingsFeature", dependencies: [tca, "SettingsClient"]),
        .target(name: "SignInFeature", dependencies: [tca, "AccountClient", "StyleGuide"]),
        .target(name: "DiscoverFeature", dependencies: [tca, "ContestClient"]),
        .target(name: "MyProfileFeature", dependencies: [tca, "StyleGuide", "AccountClient", "SignInFeature"]),
        .target(name: "MainNavigationFeature", dependencies: [tca, "SignInFeature", "DiscoverFeature", "MyProfileFeature", "SettingsFeature"]),
        
        .testTarget(name: "SignInFeatureTests", dependencies: ["SignInFeature"]),
    ]
)
