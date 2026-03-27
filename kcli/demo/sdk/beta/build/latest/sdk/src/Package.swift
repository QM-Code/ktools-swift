// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KcliSwift",
    products: [
        .library(name: "Kcli", targets: ["Kcli"]),
        .library(name: "KcliDemoSupport", targets: ["KcliDemoSupport"]),
        .library(name: "KcliDemoAlpha", targets: ["KcliDemoAlpha"]),
        .library(name: "KcliDemoBeta", targets: ["KcliDemoBeta"]),
        .library(name: "KcliDemoGamma", targets: ["KcliDemoGamma"]),
        .executable(name: "kcli-demo-bootstrap", targets: ["KcliDemoBootstrap"]),
        .executable(name: "kcli-demo-core", targets: ["KcliDemoCore"]),
        .executable(name: "kcli-demo-omega", targets: ["KcliDemoOmega"]),
    ],
    targets: [
        .target(
            name: "Kcli"
        ),
        .target(
            name: "KcliDemoSupport",
            dependencies: ["Kcli"]
        ),
        .target(
            name: "KcliDemoAlpha",
            dependencies: ["KcliDemoSupport"]
        ),
        .target(
            name: "KcliDemoBeta",
            dependencies: ["KcliDemoSupport"]
        ),
        .target(
            name: "KcliDemoGamma",
            dependencies: ["KcliDemoSupport"]
        ),
        .executableTarget(
            name: "KcliDemoBootstrap",
            dependencies: ["Kcli"]
        ),
        .executableTarget(
            name: "KcliDemoCore",
            dependencies: ["KcliDemoSupport"]
        ),
        .executableTarget(
            name: "KcliDemoOmega",
            dependencies: ["KcliDemoSupport"]
        ),
        .testTarget(
            name: "KcliTests",
            dependencies: ["Kcli"]
        ),
        .testTarget(
            name: "KcliDemoTests",
            dependencies: ["KcliDemoSupport"]
        ),
    ]
)
