// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Deli",
    products: [
        .executable(name: "deli", targets: ["deli"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.21.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "1.0.0"),
        .package(url: "https://github.com/crossroadlabs/Regex.git", from: "1.1.0"),
        .package(url: "https://github.com/tuist/xcodeproj.git", from: "6.0.0"),
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.15.0")
    ],
    targets: [
        .target(
            name: "deli",
            dependencies: [
                "SourceKittenFramework",
                "Yams",
                "Regex",
                "xcodeproj",
                "Commandant"
            ],
            path: "Sources/Deli"
        )
    ]
)
