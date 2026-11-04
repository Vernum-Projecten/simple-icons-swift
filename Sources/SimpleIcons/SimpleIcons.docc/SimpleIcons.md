# ``SimpleIcons``

Every brand icon of Simple Icons, as typed Swift constants.

## Overview

[Simple Icons](https://simpleicons.org) collects SVG icons for thousands of
brands, each a single path in a 24 by 24 box with the brand's color. This
module holds all of them, generated from a pinned Simple Icons release:

```swift
import SimpleIcons

let icon = SimpleIcon.swift
icon.title   // "Swift"
icon.hex     // "F05138"
icon.svg     // the SVG document, as Simple Icons publishes it

SimpleIcon.allCases.count  // every icon
```

Every icon is a constant named after its slug, so the compiler checks each
name and Xcode completes it; no lookup can fail and nothing is optional.

The module needs only Foundation, so it works on every platform Swift runs
on, servers included. To draw an icon in SwiftUI, add `SimpleIconsSwiftUI`.

> Important: Simple Icons is released under CC0, but the brands are not.
> Read the [legal disclaimer](https://github.com/simple-icons/simple-icons/blob/develop/DISCLAIMER.md),
> check each icon's `license` and follow the brand's
> `guidelines` before you use an icon.

## Topics

### Icons

- ``SimpleIcon``
- ``SimpleIcon/allCases``
- ``SimpleIcon/simpleIconsVersion``

### Metadata

- ``SimpleIcon/License-swift.enum``
- ``SimpleIcon/Aliases``
- ``SimpleIcon/Duplicate``
- ``SimpleIcon/Guidelines-swift.enum``

### SVG

- ``SimpleIcon/svg-swift.property``
- ``SimpleIcon/svg(fill:)``

### Drawing with any graphics API

- ``SimpleIcon/svgPath``
- ``SVGPath``
