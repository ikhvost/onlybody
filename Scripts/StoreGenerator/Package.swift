// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "StoreGenerator",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(
            name: "StoreGenerator",
            path: "Sources"
        )
    ]
)
