import SimpleIcons

// The icons the size test allows; any other icon in the binary fails it.
let icons: [SimpleIcon] = [.github(), .swift(), .apple(), .xcode(), .figma(), .kotlin()]
for icon in icons {
    print(icon.title, icon.hex, icon.svg.utf8.count, icon.svgPath.elements.count)
}
