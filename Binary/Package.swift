// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Deli",
    products: [
        .executable(name: "deli", targets: ["deli"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.28.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        .package(url: "https://github.com/crossroadlabs/Regex.git", from: "1.2.0"),
        .package(url: "https://github.com/tuist/xcodeproj.git", from: "7.5.0"),
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.17.0")
    ],
    targets: [
        .target(
            name: "deli",
            dependencies: [
                "SourceKittenFramework",
                "Yams",
                "Regex",
                "XcodeProj",
                "Commandant"
            ],
            path: "Sources/Deli"
        )
    ]
)
