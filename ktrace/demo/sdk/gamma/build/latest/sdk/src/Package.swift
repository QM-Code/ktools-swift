// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KtraceSwift",
    products: [
        .library(name: "Ktrace", targets: ["Ktrace"]),
        .library(name: "KtraceDemoAlpha", targets: ["KtraceDemoAlpha"]),
        .library(name: "KtraceDemoBeta", targets: ["KtraceDemoBeta"]),
        .library(name: "KtraceDemoGamma", targets: ["KtraceDemoGamma"]),
        .library(name: "KtraceDemoSupport", targets: ["KtraceDemoSupport"]),
        .executable(name: "ktrace-demo-bootstrap", targets: ["KtraceDemoBootstrap"]),
        .executable(name: "ktrace-demo-core", targets: ["KtraceDemoCore"]),
        .executable(name: "ktrace-demo-omega", targets: ["KtraceDemoOmega"]),
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
        .target(
            name: "KtraceDemoAlpha",
            dependencies: ["Ktrace"]
        ),
        .target(
            name: "KtraceDemoBeta",
            dependencies: ["Ktrace"]
        ),
        .target(
            name: "KtraceDemoGamma",
            dependencies: ["Ktrace"]
        ),
        .target(
            name: "KtraceDemoSupport",
            dependencies: [
                "Ktrace",
                "KtraceDemoAlpha",
                "KtraceDemoBeta",
                "KtraceDemoGamma",
                .product(name: "Kcli", package: "swiftpkg-kcli"),
            ]
        ),
        .executableTarget(
            name: "KtraceDemoBootstrap",
            dependencies: ["KtraceDemoSupport"]
        ),
        .executableTarget(
            name: "KtraceDemoCore",
            dependencies: ["KtraceDemoSupport"]
        ),
        .executableTarget(
            name: "KtraceDemoOmega",
            dependencies: ["KtraceDemoSupport"]
        ),
        .testTarget(
            name: "KtraceTests",
            dependencies: ["Ktrace"]
        ),
        .testTarget(
            name: "KtraceDemoTests",
            dependencies: ["KtraceDemoSupport"]
        ),
    ]
)
