// swift-tools-version: 6.2
// Two small programs that use six icons, built in release by
// scripts/checks/size-probe.sh to prove that an app contains only the icons
// it names (#12, #13). A package of its own, so people who add
// simple-icons-swift never fetch it.

import PackageDescription

// scripts/checks/size-probe.sh sets SIZE_PROBE_PACKAGE to measure another
// copy of the package, to prove that the check fails when it should.
let iconsPackage = Context.environment["SIZE_PROBE_PACKAGE"] ?? "../.."

let package = Package(
    name: "SizeProbe",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(name: "simple-icons-swift", path: iconsPackage)
    ],
    targets: [
        // Six icons through SimpleIcons only, as a server or a script uses it.
        .executableTarget(
            name: "SizeProbe",
            dependencies: [.product(name: "SimpleIcons", package: "simple-icons-swift")]
        ),
        // The same six icons drawn with SimpleIconsSwiftUI, as an app does.
        .executableTarget(
            name: "SizeProbeUI",
            dependencies: [.product(name: "SimpleIconsSwiftUI", package: "simple-icons-swift")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
