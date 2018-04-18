// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Deli",
    products: [
        .library(name: "Deli", targets: ["Deli"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Deli",
            dependencies: [],
            path: "Sources/Deli"
        ),
        .testTarget(
            name: "DeliTests",
            dependencies: [
                "Deli"
            ],
            path: "Tests/DeliTests"
        )
    ],
    swiftLanguageVersions: [3, 4]
)
