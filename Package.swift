// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Deli",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(name: "Deli", targets: ["Deli"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", .exact("2.2.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .exact("8.0.2"))
    ],
    targets: [
        .target(
            name: "Deli",
            dependencies: [],
            path: "Sources/Deli"
        ),
        .testTarget(
            name: "DeliTests",
            dependencies: [
                "Deli",
                "Quick",
                "Nimble"
            ],
            path: "Tests/DeliTests"
        )
    ],
    swiftLanguageVersions: [.v4, .v4_2, .v5]
)
