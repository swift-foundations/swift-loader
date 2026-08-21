// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-loader",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Loader",
            targets: ["Loader"]
        ),
        .library(
            name: "Loader Test Support",
            targets: ["Loader Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-loader-primitives.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-foundations/swift-posix.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-darwin.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-linux.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Type Metadata Shims"
        ),
        .target(
            name: "Loader",
            dependencies: [
                "Type Metadata Shims",
                .product(name: "Loader Primitives", package: "swift-loader-primitives"),
                .product(
                    name: "POSIX Loader",
                    package: "swift-posix",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(
                    name: "Darwin Loader",
                    package: "swift-darwin",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS])
                ),
                .product(
                    name: "Linux Loader",
                    package: "swift-linux",
                    condition: .when(platforms: [.linux])
                ),
            ]
        ),
        .target(
            name: "Loader Test Support",
            dependencies: [
                "Loader"
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Loader Tests",
            dependencies: [
                "Loader",
                "Loader Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
