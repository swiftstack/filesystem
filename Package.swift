// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "File",
    products: [
        .library(name: "File", targets: ["File"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-stack/platform.git",
            .branch("master")),
        .package(
            url: "https://github.com/swift-stack/stream.git",
            .branch("master")),
        .package(
            url: "https://github.com/swift-stack/test.git",
            .branch("master")),
    ],
    targets: [
        .target(
            name: "File",
            dependencies: ["Platform", "Stream"]),
        .testTarget(
            name: "FileTests",
            dependencies: ["Test", "File"]),
    ]
)
