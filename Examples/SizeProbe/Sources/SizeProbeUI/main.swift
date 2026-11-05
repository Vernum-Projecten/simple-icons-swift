import SimpleIcons

#if canImport(SwiftUI)
import SimpleIconsSwiftUI
import SwiftUI

// The six icons of SizeProbe, through the shape, the path and the color.
let icons: [SimpleIcon] = [.github(), .swift(), .apple(), .xcode(), .figma(), .kotlin()]
for icon in icons {
    let path = SimpleIconShape(icon).path(in: CGRect(x: 0, y: 0, width: 48, height: 48))
    print(icon.title, path.boundingRect, Color(simpleIcon: icon))
}
#else
print("SimpleIconsSwiftUI needs SwiftUI; nothing to measure on this platform.")
#endif
