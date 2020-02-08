// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PodKeeper",
    platforms: [
        .macOS(.v10_13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-tools-support-core.git", from: "0.0.1"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0-rc.3")
    ],
    targets: [
        .target(
            name: "PodKeeper",
            dependencies: ["Alamofire", "SwiftToolsSupport"]),
        .testTarget(
            name: "PodKeeperTests",
            dependencies: ["PodKeeper"]),
    ]
)
