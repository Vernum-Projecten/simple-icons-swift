# Getting Started

Add the package, find an icon's name, and show it in SwiftUI.

## Add the package

In Xcode choose **File > Add Package Dependencies…**, paste
`https://github.com/Vernum-Projecten/simple-icons-swift.git`, and add the
`SimpleIconsSwiftUI` library to your app target. In a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Vernum-Projecten/simple-icons-swift.git", from: "16.36.0"),
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [.product(name: "SimpleIconsSwiftUI", package: "simple-icons-swift")]
    ),
]
```

The package's version is the Simple Icons version it holds: 16.36.0 has
the icons of Simple Icons 16.36.0. `SimpleIconsSwiftUI` brings the icons
with it. Add only `SimpleIcons` for
code without a user interface, such as a server.

## Find an icon's name

Search [simpleicons.org](https://simpleicons.org). The constant is named
after the icon's slug: the brand name in lowercase letters and digits, so
"Node.js" is `.nodedotjs` and ".NET" is `.dotnet`. Xcode completes the
names as you type `SimpleIcon.`.

## Show an icon

``SimpleIconView`` behaves like `Image(systemName:)`: it is square, draws
in the foreground style and has the brand's name as its accessibility
label.

```swift
import SimpleIconsSwiftUI

struct BuiltWith: View {
    var body: some View {
        Label {
            Text("Built with Swift")
        } icon: {
            SimpleIconView(.swift)
        }
    }
}
```

Give it the brand color with `Color(simpleIcon:)`, and a size with
`frame`:

```swift
SimpleIconView(.github)
    .foregroundStyle(Color(simpleIcon: .github))
    .frame(width: 44, height: 44)
```

Use ``SimpleIconShape`` to stroke, clip or animate an icon like any other
`Shape`.

## Before you ship

Simple Icons is CC0, but the brands are not. Read the
[legal disclaimer](https://github.com/simple-icons/simple-icons/blob/develop/DISCLAIMER.md),
check each icon's `license` and follow the brand's `guidelines`.
