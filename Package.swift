// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaCrop",
    defaultLocalization: "en",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MediaCrop",
            targets: ["MediaCrop"]),
    ],
    dependencies: [
        .package(url: "https://github.com/zjinhu/Brick_SwiftUI.git", .upToNextMajor(from: "0.3.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MediaCrop",
            dependencies:
                [
                    .product(name: "BrickKit", package: "Brick_SwiftUI"), 
                ],
            resources: [.process("Resources")]),
    ]
)

package.platforms = [
    .iOS(.v14),
]
package.swiftLanguageVersions = [.v5]
