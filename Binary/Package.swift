// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Deli",
    products: [
        .executable(name: "deli", targets: ["deli"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.20.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "0.7.0"),
        .package(url: "https://github.com/crossroadlabs/Regex.git", from: "1.1.0"),
        .package(url: "https://github.com/xcodeswift/xcproj.git", from: "4.3.0"),
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.13.0")
    ],
    targets: [
        .target(
            name: "deli",
            dependencies: [
                "SourceKittenFramework",
                "Yams",
                "Regex",
                "xcproj",
                "Commandant"
            ]
        )
    ]
)
