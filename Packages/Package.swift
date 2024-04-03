// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Main",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .singleTargetLibrary("AppModule"),
        .singleTargetLibrary("PlaybookModule"),
    ],
    dependencies: [
        .package(url: "https://github.com/krzysztofzablocki/Inject.git", exact: "1.2.3"),
        .package(url: "https://github.com/realm/SwiftLint", exact: "0.54.0"),
        .package(url: "https://github.com/krzysztofzablocki/Difference.git", exact: "1.0.2"),
        .package(url: "https://github.com/krzysztofzablocki/LifetimeTracker.git", exact: "1.8.2"),
        .package(url: "https://github.com/playbook-ui/playbook-ios", exact: "0.3.4"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.12.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "1.9.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.2.2"),
        .package(url: "https://github.com/Dashlane/SwiftDomainParser", exact: "1.1.0"),
    ],
    targets: [
        .target(
            name: "AppModule",
            dependencies: [
                "ARContainerModule",
                "AROverlayModule",
                "Extensions",
                "SharedViews",
                "SharedModels",
                "LocationClient",
                .product(name: "LifetimeTracker", package: "LifetimeTracker"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "ARContainerModule",
            dependencies: [
                "Extensions",
                "SharedViews",
                "SharedModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "AROverlayModule",
            dependencies: [
                "BrowserModule",
                "NavigatorModule",
                "NewTabModule",
                "QRCodeOverlayModule",
                "Extensions",
                "SharedViews",
                "SharedModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "BrowserModule",
            dependencies: [
                "Extensions",
                "SharedViews",
                "SharedModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "QRCodeOverlayModule",
            dependencies: [
                "Extensions",
                "SharedViews",
                "SharedModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "NavigatorModule",
            dependencies: [
                "TabModule",
                "LocationClient",
                "Extensions",
                "SharedViews",
                "SharedModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "NewTabModule",
            dependencies: [
                "Extensions",
                "SharedViews",
                "SharedModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "TabModule",
            dependencies: [
                "Extensions",
                "SharedViews",
                "SharedModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "PlaybookModule",
            dependencies: [
                "Extensions",
                "SharedViews",
                "SharedModels",
                "Inject",
                .product(name: "Playbook", package: "playbook-ios"),
                .product(name: "PlaybookUI", package: "playbook-ios"),
            ]
        ),
        .target(
            name: "TestExtensions",
            dependencies: [
                .product(name: "Difference", package: "Difference"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
        .target(
            name: "LocationClient",
            dependencies: [
                "Extensions",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "Extensions",
            dependencies: [
                "SharedModels",
                .product(name: "DomainParser", package: "SwiftDomainParser"),
            ]
        ),
        .target(
            name: "SharedViews",
            dependencies: [
                .product(name: "Inject", package: "Inject"),
            ]
        ),
        .target(
            name: "SharedModels",
            dependencies: [
                .product(name: "Difference", package: "Difference"),
                .product(name: "LifetimeTracker", package: "LifetimeTracker"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
)

// Inject base plugins into each target
package.targets = package.targets.map { target in
    var plugins = target.plugins ?? []
    plugins.append(.plugin(name: "SwiftLintPlugin", package: "SwiftLint"))
    target.plugins = plugins
    return target
}

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
