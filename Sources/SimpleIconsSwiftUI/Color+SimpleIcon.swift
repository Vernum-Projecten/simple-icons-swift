#if canImport(SwiftUI)
public import SwiftUI
public import SimpleIcons

extension Color {
    /// Creates the brand color of an icon, in the sRGB color space.
    ///
    /// ```swift
    /// SimpleIconView(.swift)
    ///     .foregroundStyle(Color(simpleIcon: .swift))
    /// ```
    ///
    /// Some brand colors are very dark or very light; check the contrast
    /// against your background in light and dark appearance.
    public init(simpleIcon icon: SimpleIcon) {
        let (red, green, blue) = Self.components(ofHex: icon.hex)
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }

    /// The red, green and blue of six hexadecimal digits, from 0 to 1. Black
    /// for anything else, which no icon in Simple Icons has.
    static func components(ofHex hex: String) -> (Double, Double, Double) {
        guard hex.utf8.count == 6, let value = UInt32(hex, radix: 16) else { return (0, 0, 0) }
        return (
            Double((value >> 16) & 0xFF) / 255,
            Double((value >> 8) & 0xFF) / 255,
            Double(value & 0xFF) / 255
        )
    }
}
#endif
