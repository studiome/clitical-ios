// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CLPatientData",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "CLPatientData",
            targets: ["CLPatientData"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CLPatientData",
            dependencies: []),
        .testTarget(
            name: "CLPatientDataTests",
            dependencies: ["CLPatientData"]),
    ]
)
