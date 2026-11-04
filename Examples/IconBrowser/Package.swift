// swift-tools-version: 6.2
// An example app: every icon in a searchable grid, with a detail view per
// icon. A package of its own, so people who add simple-icons-swift never
// fetch it. Run it on macOS with `swift run --package-path Examples/IconBrowser`;
// on iOS, add the IconBrowserFeature library to an app target and show
// IconBrowserView.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
    name: "IconBrowser",
    platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
    products: [
        .library(name: "IconBrowserFeature", targets: ["IconBrowserFeature"]),
        .executable(name: "IconBrowser", targets: ["IconBrowser"]),
    ],
    dependencies: [
        .package(name: "simple-icons-swift", path: "../..")
    ],
    targets: [
        // The screens and their model, for any app on any Apple platform.
        .target(
            name: "IconBrowserFeature",
            dependencies: [.product(name: "SimpleIconsSwiftUI", package: "simple-icons-swift")],
            swiftSettings: swiftSettings
        ),
        // The macOS app around them.
        .executableTarget(
            name: "IconBrowser",
            dependencies: ["IconBrowserFeature"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "IconBrowserFeatureTests",
            dependencies: ["IconBrowserFeature"],
            swiftSettings: swiftSettings
        ),
    ],
    swiftLanguageModes: [.v6]
)
