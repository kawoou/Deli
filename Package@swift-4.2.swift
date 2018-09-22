// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Deli",
    products: [
        .library(name: "Deli", targets: ["Deli"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "1.3.1"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "7.3.0")
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
    swiftLanguageVersions: [.v3, .v4, .v4_2]
)
