// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mux-stats-sdk-kaltura-ios",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MUXSDKStatsKaltura",
            targets: ["MUXSDKStatsKaltura"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/muxinc/stats-sdk-objc.git",
            from: "4.5.2"
        ),
        .package(
            url: "https://github.com/kaltura/playkit-ios.git",
            from: "3.27.2"
        )
    ],
    targets: [
        .target(
            name: "MUXSDKStatsKaltura",
            dependencies: [
                .product(
                    name: "MuxCore",
                    package: "stats-sdk-objc"
                ),
                .product(
                    name: "PlayKit",
                    package: "playkit-ios"
                ),
            ]
        ),
        .testTarget(
            name: "MUXSDKStatsKalturaTests",
            dependencies: [
                "MUXSDKStatsKaltura",
                .product(
                    name: "MuxCore",
                    package: "stats-sdk-objc"
                ),
                .product(
                    name: "PlayKit",
                    package: "playkit-ios"
                ),
            ]
        ),
    ]
)
