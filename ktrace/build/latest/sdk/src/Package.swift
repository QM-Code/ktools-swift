// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KtraceSwift",
    products: [
        .library(name: "Ktrace", targets: ["Ktrace"]),
    ],
    dependencies: [
        .package(path: "../../kcli/swiftpkg-kcli"),
    ],
    targets: [
        .target(
            name: "Ktrace",
            dependencies: [
                .product(name: "Kcli", package: "swiftpkg-kcli"),
            ]
        ),
        .testTarget(
            name: "KtraceTests",
            dependencies: ["Ktrace"]
        ),
    ]
)
