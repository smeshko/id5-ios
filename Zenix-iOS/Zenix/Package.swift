// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let tca = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let entities = Target.Dependency.product(name: "Entities", package: "entities")
let common = Target.Dependency.product(name: "Common", package: "common")

let package = Package(
    name: "Zenix",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "NetworkClient", targets: ["NetworkClient"]),
        .library(name: "AccountClient", targets: ["AccountClient"]),
        .library(name: "ContestClient", targets: ["ContestClient"]),
        .library(name: "KeychainClient", targets: ["KeychainClient"]),
        .library(name: "SettingsClient", targets: ["SettingsClient"]),
        .library(name: "Endpoints", targets: ["Endpoints"]),
        .library(name: "Helpers", targets: ["Helpers"]),
        .library(name: "StyleGuide", targets: ["StyleGuide"]),
        
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
    ],
    targets: [
        .target(name: "StyleGuide"),
        .target(name: "SettingsClient", dependencies: [tca]),
        .target(name: "Helpers", dependencies: [entities]),
        .target(name: "Endpoints", dependencies: [tca, common, "SettingsClient"]),
        .target(name: "KeychainClient", dependencies: [tca, .product(name: "SwiftKeychainWrapper", package: "SwiftKeychainWrapper")]),
        .target(name: "NetworkClient", dependencies: [entities, tca, "KeychainClient", "Endpoints", "Helpers"]),
        .target(name: "AccountClient", dependencies: [entities, common, tca, "NetworkClient", "Endpoints", "Helpers"]),
        .target(name: "ContestClient", dependencies: [entities, common, tca, "NetworkClient", "Endpoints"]),

        .target(name: "AppFeature", dependencies: [tca, "MainNavigationFeature"]),
        .target(name: "SettingsFeature", dependencies: [tca]),
        .target(name: "SignInFeature", dependencies: [tca, "AccountClient", "StyleGuide"]),
        .target(name: "DiscoverFeature", dependencies: [tca, "ContestClient"]),
        .target(name: "MyProfileFeature", dependencies: [tca, "StyleGuide", "AccountClient", "SignInFeature"]),
        .target(name: "MainNavigationFeature", dependencies: [tca, "SignInFeature", "DiscoverFeature", "MyProfileFeature", "SettingsFeature"]),
        
        .testTarget(name: "SignInFeatureTests", dependencies: ["SignInFeature"]),
    ]
)
