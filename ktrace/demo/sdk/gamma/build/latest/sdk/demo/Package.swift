// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KtraceSwiftDemos",
    products: [
        .library(name: "KtraceDemoAlpha", targets: ["KtraceDemoAlpha"]),
        .library(name: "KtraceDemoBeta", targets: ["KtraceDemoBeta"]),
        .library(name: "KtraceDemoGamma", targets: ["KtraceDemoGamma"]),
        .library(name: "KtraceDemoSupport", targets: ["KtraceDemoSupport"]),
        .executable(name: "ktrace-demo-bootstrap", targets: ["KtraceDemoBootstrap"]),
        .executable(name: "ktrace-demo-core", targets: ["KtraceDemoCore"]),
        .executable(name: "ktrace-demo-omega", targets: ["KtraceDemoOmega"]),
    ],
    dependencies: [
        .package(path: "../swiftpkg-ktrace"),
        .package(path: "../../kcli/swiftpkg-kcli"),
    ],
    targets: [
        .target(
            name: "KtraceDemoAlpha",
            dependencies: [
                .product(name: "Ktrace", package: "swiftpkg-ktrace"),
            ],
            path: "sdk/alpha/src"
        ),
        .target(
            name: "KtraceDemoBeta",
            dependencies: [
                .product(name: "Ktrace", package: "swiftpkg-ktrace"),
            ],
            path: "sdk/beta/src"
        ),
        .target(
            name: "KtraceDemoGamma",
            dependencies: [
                .product(name: "Ktrace", package: "swiftpkg-ktrace"),
            ],
            path: "sdk/gamma/src"
        ),
        .target(
            name: "KtraceDemoSupport",
            dependencies: [
                .product(name: "Ktrace", package: "swiftpkg-ktrace"),
                "KtraceDemoAlpha",
                "KtraceDemoBeta",
                "KtraceDemoGamma",
                .product(name: "Kcli", package: "swiftpkg-kcli"),
            ],
            path: "common/src"
        ),
        .executableTarget(
            name: "KtraceDemoBootstrap",
            dependencies: ["KtraceDemoSupport"],
            path: "bootstrap/src"
        ),
        .executableTarget(
            name: "KtraceDemoCore",
            dependencies: ["KtraceDemoSupport"],
            path: "exe/core/src"
        ),
        .executableTarget(
            name: "KtraceDemoOmega",
            dependencies: ["KtraceDemoSupport"],
            path: "exe/omega/src"
        ),
        .testTarget(
            name: "KtraceDemoTests",
            dependencies: ["KtraceDemoSupport"],
            path: "Tests/KtraceDemoTests"
        ),
    ]
)
