// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KcliSwiftDemos",
    products: [
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
            name: "KcliDemoAlpha",
            dependencies: [
                .product(name: "Kcli", package: "swiftpkg-kcli"),
            ],
            path: "sdk/alpha/src"
        ),
        .target(
            name: "KcliDemoBeta",
            dependencies: [
                .product(name: "Kcli", package: "swiftpkg-kcli"),
            ],
            path: "sdk/beta/src"
        ),
        .target(
            name: "KcliDemoGamma",
            dependencies: [
                .product(name: "Kcli", package: "swiftpkg-kcli"),
            ],
            path: "sdk/gamma/src"
        ),
        .target(
            name: "KcliDemoCoreSupport",
            dependencies: [
                .product(name: "Kcli", package: "swiftpkg-kcli"),
                "KcliDemoAlpha",
            ],
            path: "exe/core",
            exclude: ["README.md", "src", "build"],
            sources: ["DemoCore.swift"]
        ),
        .target(
            name: "KcliDemoOmegaSupport",
            dependencies: [
                .product(name: "Kcli", package: "swiftpkg-kcli"),
                "KcliDemoAlpha",
                "KcliDemoBeta",
                "KcliDemoGamma",
            ],
            path: "exe/omega",
            exclude: ["README.md", "src", "build"],
            sources: ["DemoOmega.swift"]
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
            dependencies: ["KcliDemoCoreSupport"],
            path: "exe/core/src"
        ),
        .executableTarget(
            name: "KcliDemoOmega",
            dependencies: ["KcliDemoOmegaSupport"],
            path: "exe/omega/src"
        ),
        .testTarget(
            name: "KcliDemoTests",
            dependencies: ["KcliDemoCoreSupport", "KcliDemoOmegaSupport"],
            path: "Tests/KcliDemoTests"
        ),
    ]
)
