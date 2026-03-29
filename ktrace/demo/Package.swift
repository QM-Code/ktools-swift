// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KtraceSwiftDemos",
    products: [
        .library(name: "KtraceDemoAlpha", targets: ["KtraceDemoAlpha"]),
        .library(name: "KtraceDemoBeta", targets: ["KtraceDemoBeta"]),
        .library(name: "KtraceDemoGamma", targets: ["KtraceDemoGamma"]),
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
            name: "KtraceDemoCoreSupport",
            dependencies: [
                .product(name: "Ktrace", package: "swiftpkg-ktrace"),
                .product(name: "Kcli", package: "swiftpkg-kcli"),
                "KtraceDemoAlpha",
            ],
            path: "exe/core/support"
        ),
        .target(
            name: "KtraceDemoOmegaSupport",
            dependencies: [
                .product(name: "Ktrace", package: "swiftpkg-ktrace"),
                .product(name: "Kcli", package: "swiftpkg-kcli"),
                "KtraceDemoAlpha",
                "KtraceDemoBeta",
                "KtraceDemoGamma",
            ],
            path: "exe/omega/support"
        ),
        .executableTarget(
            name: "KtraceDemoBootstrap",
            dependencies: [
                .product(name: "Ktrace", package: "swiftpkg-ktrace"),
            ],
            path: "bootstrap/src"
        ),
        .executableTarget(
            name: "KtraceDemoCore",
            dependencies: ["KtraceDemoCoreSupport"],
            path: "exe/core/src"
        ),
        .executableTarget(
            name: "KtraceDemoOmega",
            dependencies: ["KtraceDemoOmegaSupport"],
            path: "exe/omega/src"
        ),
        .testTarget(
            name: "KtraceDemoTests",
            dependencies: ["KtraceDemoCoreSupport", "KtraceDemoOmegaSupport"],
            path: "Tests/KtraceDemoTests"
        ),
    ]
)
