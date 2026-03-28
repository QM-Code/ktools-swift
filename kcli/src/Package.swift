// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KcliSwift",
    products: [
        .library(name: "Kcli", targets: ["Kcli"]),
    ],
    targets: [
        .target(
            name: "Kcli"
        ),
        .testTarget(
            name: "KcliTests",
            dependencies: ["Kcli"]
        ),
    ]
)
