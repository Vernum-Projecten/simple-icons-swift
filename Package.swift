// swift-tools-version: 6.2
// The Swift 6.2 tools are the floor because the generated icon constants use
// raw identifiers (SE-0451) for slugs that start with a digit, such as
// `1password`.

import PackageDescription

/// Settings every target shares: Swift 6 language mode, plus the upcoming
/// features that become defaults in a later language mode, so the code is
/// already written the way that mode wants it.
let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
    name: "simple-icons-swift",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "SimpleIcons", targets: ["SimpleIcons"]),
        .library(name: "SimpleIconsSwiftUI", targets: ["SimpleIconsSwiftUI"]),
    ],
    targets: [
        // The icons and their metadata, the SVG markup and the parsed path.
        // Needs only Foundation (for the arc math), so it builds on every
        // platform Swift runs on, Linux included.
        .target(
            name: "SimpleIcons",
            swiftSettings: swiftSettings
        ),
        // Draws an icon in SwiftUI: a Shape, a View and the brand Color.
        .target(
            name: "SimpleIconsSwiftUI",
            dependencies: ["SimpleIcons"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SimpleIconsTests",
            dependencies: ["SimpleIcons"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SimpleIconsSwiftUITests",
            dependencies: ["SimpleIconsSwiftUI"],
            swiftSettings: swiftSettings
        ),
    ],
    swiftLanguageModes: [.v6]
)
