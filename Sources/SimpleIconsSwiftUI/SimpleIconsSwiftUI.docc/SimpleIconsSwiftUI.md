# ``SimpleIconsSwiftUI``

Show Simple Icons brand icons in SwiftUI, the way SF Symbols are shown.

## Overview

``SimpleIconView`` shows an icon like `Image(systemName:)` shows a symbol:
square, in the foreground style, and labeled with the brand's name for
VoiceOver.

```swift
import SimpleIcons
import SimpleIconsSwiftUI

Label {
    Text("Built with Swift")
} icon: {
    SimpleIconView(.swift())
}

SimpleIconView(.github())
    .foregroundStyle(Color(simpleIcon: .github()))
    .frame(width: 44, height: 44)
```

``SimpleIconShape`` is the icon as a `Shape`, to fill, stroke, clip or
animate like any other shape. `Path(_:)` gives the icon's path in its own
24 by 24 coordinate space, and `Color(simpleIcon:)` the brand color.

> Important: Simple Icons is released under CC0, but the brands are not.
> Read the [legal disclaimer](https://github.com/simple-icons/simple-icons/blob/develop/DISCLAIMER.md)
> and follow each brand's guidelines before you use an icon.

## Topics

### Essentials

- <doc:GettingStarted>

### Showing an icon

- ``SimpleIconView``
- ``SimpleIconShape``
