// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KcliSwiftDemos",
    products: [
        .library(name: "KcliDemoSupport", targets: ["KcliDemoSupport"]),
        .library(name: "KcliDemoAlpha", targets: ["KcliDemoAlpha"]),
        .library(name: "KcliDemoBeta", targets: ["KcliDemoBeta"]),
        .library(name: "KcliDemoGamma", targets: ["KcliDemoGamma"]),
        .executable(name: "kcli-demo-bootstrap", targets: ["KcliDemoBootstrap"]),
        .executable(name: "kcli-demo-core", targets: ["KcliDemoCore"]),
        .executable(name: "kcli-demo-omega", targets: ["KcliDemoOmega"]),
    ],
    dependencies: [
        .package(path: "../swiftpkg-kcli"),
    ],
    targets: [
        .target(
            name: "KcliDemoSupport",
            dependencies: [
                .product(name: "Kcli", package: "swiftpkg-kcli"),
            ],
            path: "common/src"
        ),
        .target(
            name: "KcliDemoAlpha",
            dependencies: ["KcliDemoSupport"],
            path: "sdk/alpha/src"
        ),
        .target(
            name: "KcliDemoBeta",
            dependencies: ["KcliDemoSupport"],
            path: "sdk/beta/src"
        ),
        .target(
            name: "KcliDemoGamma",
            dependencies: ["KcliDemoSupport"],
            path: "sdk/gamma/src"
        ),
        .executableTarget(
            name: "KcliDemoBootstrap",
            dependencies: [
                .product(name: "Kcli", package: "swiftpkg-kcli"),
            ],
            path: "bootstrap/src"
        ),
        .executableTarget(
            name: "KcliDemoCore",
            dependencies: ["KcliDemoSupport"],
            path: "exe/core/src"
        ),
        .executableTarget(
            name: "KcliDemoOmega",
            dependencies: ["KcliDemoSupport"],
            path: "exe/omega/src"
        ),
        .testTarget(
            name: "KcliDemoTests",
            dependencies: ["KcliDemoSupport"],
            path: "Tests/KcliDemoTests"
        ),
    ]
)
