// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lilac",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.7.0"),
        .package(url: "https://github.com/apple/swift-configuration.git", from: "1.1.0"),
        .package(url: "https://github.com/mattt/swift-configuration-toml.git", from: "2.0.0"),
        .package(url: "https://github.com/mattt/swift-toml.git", from: "2.0.0"),
        .package(url: "https://github.com/davbeck/swift-glob.git", from: "1.0.0"),
        .package(url: "https://github.com/ibrahimcetin/SwiftGitX.git", from: "0.4.0"),
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "4.0.0"),
        // .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.11.0")),
    ],
    targets: [
        .target(
            name: "LilacCore",
            dependencies: [
                .product(name: "Configuration", package: "swift-configuration"),
                .product(name: "ConfigurationTOML", package: "swift-configuration-toml"),
                .product(name: "TOML", package: "swift-toml"),
                .product(name: "Glob", package: "swift-glob"),
                .product(name: "SwiftGitX", package: "SwiftGitX"),
                .product(name: "Rainbow", package: "Rainbow"),
                // .product(name: "Alamofire", package: "Alamofire"),
            ]
        ),
        .executableTarget(
            name: "LilacCLI",
            dependencies: [
                "LilacCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "TOML", package: "swift-toml"),
                .product(name: "Glob", package: "swift-glob"),
            ]
        ),
    ]
)
