<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/logo-dark.svg">
  <img src="docs/images/logo-light.svg" width="96" height="96" alt="The simple-icons-swift logo: a grid of rounded tiles with one orange tile in the middle">
</picture>

# simple-icons-swift

**Every [Simple Icons](https://simpleicons.org) brand icon for Swift and SwiftUI, as typed constants.**

[![CI](https://github.com/Vernum-Projecten/simple-icons-swift/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Vernum-Projecten/simple-icons-swift/actions/workflows/ci.yml?query=branch%3Amain)
[![Latest release](https://img.shields.io/github/v/release/Vernum-Projecten/simple-icons-swift?label=release)](https://github.com/Vernum-Projecten/simple-icons-swift/releases/latest)
[![Simple Icons version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FVernum-Projecten%2Fsimple-icons-swift%2Fmain%2Fsimple-icons.json&query=%24.simpleIconsVersion&label=simple%20icons&color=111111)](https://github.com/simple-icons/simple-icons/releases)
[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FVernum-Projecten%2Fsimple-icons-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Vernum-Projecten/simple-icons-swift)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FVernum-Projecten%2Fsimple-icons-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Vernum-Projecten/simple-icons-swift)
[![License: MIT](https://img.shields.io/github/license/Vernum-Projecten/simple-icons-swift)](LICENSE)

[Documentation](https://swiftpackageindex.com/Vernum-Projecten/simple-icons-swift/documentation) &nbsp;&nbsp;&nbsp; [Find an icon](https://simpleicons.org) &nbsp;&nbsp;&nbsp; [Changelog](CHANGELOG.md) &nbsp;&nbsp;&nbsp; [Legal disclaimer](#legal)

</div>

```swift
import SimpleIconsSwiftUI

Label {
    Text("Built with Swift")
} icon: {
    SimpleIconView(.swift)
}
```

## Why this package

- **Typed, never optional.** Each of the 3,000+ icons is a constant:
  `SimpleIcon.swift`, `.github`, `.figma`. The compiler checks every name,
  Xcode completes it, and a lookup can never fail at run time.
- **Feels like SF Symbols.** `SimpleIconView` draws in the foreground style,
  scales to its frame, stays square, and tells VoiceOver the brand's name.
- **Exactly Simple Icons.** `svg` is the upstream file byte for byte; the
  generator checks every icon before it writes a line of Swift.
- **Every platform Swift runs on.** The `SimpleIcons` module needs only
  Foundation: icons, SVG and a parsed path on iOS, macOS, tvOS, watchOS,
  visionOS and Linux. `SimpleIconsSwiftUI` adds the views.
- **Always current.** A daily workflow spots each Simple Icons release and
  files it as an issue; the update is regenerated from the npm package,
  checked against its sha512, and released.
- **Swift 6 throughout.** Strict concurrency, everything `Sendable`, no
  force unwraps, no unsafe code, documented with DocC and tested with Swift
  Testing.

## Installation

Add the package to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Vernum-Projecten/simple-icons-swift.git", from: "1.0.0"),
],
```

and the product you need to your target:

```swift
.product(name: "SimpleIconsSwiftUI", package: "simple-icons-swift"),  // views, and the icons
.product(name: "SimpleIcons", package: "simple-icons-swift"),         // the icons only, no UI
```

In Xcode: **File > Add Package Dependencies…**, paste
`https://github.com/Vernum-Projecten/simple-icons-swift.git`, and add
`SimpleIconsSwiftUI` (or `SimpleIcons`) to your app.

| Requirement | |
| :-- | :-- |
| Swift | 6.2 or later (Xcode 26 or later) |
| Platforms | iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, Linux |

## Usage

### Find an icon's name

Search [simpleicons.org](https://simpleicons.org); the name of the constant
is the icon's slug, which is the brand name in lowercase letters and
digits: `Node.js` is `.nodedotjs`, `.NET` is `.dotnet`. A slug that starts
with a digit or is a Swift keyword takes backticks:

```swift
let names = [SimpleIcon.`1password`, .`await`, .dotnet, .nodedotjs]
```

### SwiftUI

`SimpleIconView` shows an icon the way `Image(systemName:)` shows a symbol:

```swift
HStack(spacing: 16) {
    SimpleIconView(.github)
        .foregroundStyle(Color(simpleIcon: .github))  // the brand color
        .frame(width: 44, height: 44)

    SimpleIconView(.apple)                             // the foreground style
        .frame(width: 44, height: 44)
}
```

`SimpleIconShape` is the icon as a `Shape`, to fill, stroke, clip or animate:

```swift
SimpleIconShape(.figma)
    .stroke(Color(simpleIcon: .figma), lineWidth: 0.5)
    .frame(width: 120, height: 120)
```

Every icon, in a grid:

```swift
ScrollView {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))]) {
        ForEach(SimpleIcon.allCases) { icon in
            SimpleIconView(icon)
                .foregroundStyle(Color(simpleIcon: icon))
                .frame(width: 32, height: 32)
                .help(icon.title)
        }
    }
}
```

> [!TIP]
> Some brand colors are very dark or very light, such as Apple's black.
> Check the contrast in light and dark appearance, or keep the foreground
> style.

### Metadata

```swift
let icon = SimpleIcon.swift
icon.title    // "Swift"
icon.hex      // "F05138"
icon.source   // where the icon comes from

switch icon.license {
case .spdx(let identifier): print(identifier)  // such as "CC0-1.0"
case .custom(let url): print(url)              // the brand's own terms
case .unknown: break                           // Simple Icons has no license data
}

if case .url(let url) = icon.guidelines {
    print(url)                                 // the brand's rules for using its logo
}
```

`icon.aliases` holds other names (`alsoKnownAs`, `formerTitles`), titles in
other languages (`localizedTitles`) and brands that share the icon
(`duplicates`). Search with the standard library:

```swift
let matches = SimpleIcon.allCases.filter { $0.title.localizedStandardContains("git") }
```

### SVG

```swift
let svg = SimpleIcon.swift.svg                                   // exactly the file Simple Icons publishes
let white = SimpleIcon.swift.svg(fill: "white")
let brand = SimpleIcon.swift.svg(fill: "#\(SimpleIcon.swift.hex)")
```

### UIKit, AppKit and Core Graphics

```swift
let path: CGPath = Path(SimpleIcon.swift).cgPath  // 24 by 24 points
```

### Any graphics API, on any platform

`svgPath` parses the icon into absolute drawing commands: arcs become
cubic curves, relative coordinates become absolute. It needs only
Foundation, so it works on Linux too, for example to render icons on a
server.

```swift
for element in SimpleIcon.swift.svgPath.elements {
    switch element {
    case .move(let point): ...
    case .line(let point): ...
    case .quadCurve(let point, let control): ...
    case .curve(let point, let control1, let control2): ...
    case .closeSubpath: ...
    }
}
```

Every example above is compiled and run by the tests
(`Tests/SimpleIconsSwiftUITests/ReadmeExamples.swift`).

## Staying up to date

Simple Icons releases new and updated icons every week. Every day
[`icons.yml`](.github/workflows/icons.yml) checks for a new release and
opens an issue that lists the new and removed icons. The update is made
with `scripts/dev/update-icons.sh`, which checks the npm package against
its sha512, regenerates the icons and the changelog, and goes through a
pull request and the tests like any other change. The pinned version is in
[`simple-icons.json`](simple-icons.json) and in
`SimpleIcon.simpleIconsVersion`.

The package follows [Semantic Versioning](https://semver.org) with the
Simple Icons release folded in: new icons are a minor release, updated
icons a patch, and a Simple Icons major, which removes icons and so the
constants that name them, is a major release here too
([docs/releasing.md](docs/releasing.md)).

## Legal

> [!IMPORTANT]
> Simple Icons is released under [CC0](https://github.com/simple-icons/simple-icons/blob/develop/LICENSE.md),
> but that does not mean every icon is free to use: the brands belong to
> their owners. Before you use an icon, read the Simple Icons
> [legal disclaimer](https://github.com/simple-icons/simple-icons/blob/develop/DISCLAIMER.md),
> check the icon's `license`, and follow the brand's `guidelines`.

The icons and their data are by [Simple Icons](https://simpleicons.org) and
its contributors. simple-icons-swift is not affiliated with, endorsed or
sponsored by Simple Icons or any of the brands whose icons it contains.

## Contributing

Bug reports and ideas for the package are welcome as
[issues](https://github.com/Vernum-Projecten/simple-icons-swift/issues).
A new icon, or a fix to one, belongs to
[Simple Icons](https://github.com/simple-icons/simple-icons/blob/develop/CONTRIBUTING.md),
and arrives here with their next release.

[Contributing](CONTRIBUTING.md) &nbsp;&nbsp;&nbsp; [Security](SECURITY.md) &nbsp;&nbsp;&nbsp; [Support](SUPPORT.md) &nbsp;&nbsp;&nbsp; [AI policy](AI_POLICY.md) &nbsp;&nbsp;&nbsp; [Code of conduct](CODE_OF_CONDUCT.md)

## Acknowledgements

- [Simple Icons](https://github.com/simple-icons/simple-icons), for the
  icons and the care that goes into them.
- The other [third-party libraries](https://github.com/simple-icons/simple-icons#third-party-libraries),
  among them [simpleicons-rs](https://github.com/cscnk52/simpleicons-rs),
  whose typed constants inspired this package.

## License

The code is licensed under the [MIT License](LICENSE). The icons are
[CC0](https://github.com/simple-icons/simple-icons/blob/develop/LICENSE.md)
through Simple Icons, subject to the brands' rights described under [Legal](#legal).
