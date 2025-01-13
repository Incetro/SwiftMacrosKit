// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftMacrosKit",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftMacrosKit",
            targets: ["SwiftMacrosKit"]
        ),
        .executable(
            name: "SwiftMacrosKitClient",
            targets: ["SwiftMacrosKitClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.1.1"),
        .package(url: "https://github.com/Incetro/DAO.git", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "SwiftMacrosKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "SwiftMacrosKit",
            dependencies: [
                "SwiftMacrosKitMacros",
                .product(name: "SDAO", package: "DAO")
            ]
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "SwiftMacrosKitClient",
            dependencies: [
                "SwiftMacrosKit",
                .product(name: "SDAO", package: "DAO")
            ]
        ),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "SwiftMacrosKitTests",
            dependencies: [
                "SwiftMacrosKitMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
