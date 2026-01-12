// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-loader",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Loader",
            targets: ["Loader"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-loader-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-darwin-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-linux-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-foundations/swift-posix.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-foundations/swift-darwin.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-foundations/swift-linux.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-foundations/swift-windows.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "Loader",
            dependencies: [
                .product(name: "Loader Primitives", package: "swift-loader-primitives"),
                .product(name: "POSIX Loader", package: "swift-posix", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Darwin Loader", package: "swift-darwin", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS])),
                .product(name: "Linux Loader", package: "swift-linux", condition: .when(platforms: [.linux])),
                // .product(name: "Windows Loader", package: "swift-windows", condition: .when(platforms: [.windows])),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportsByDefault"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
