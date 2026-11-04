#if canImport(SwiftUI)
public import SwiftUI
public import SimpleIcons

/// A view that shows a Simple Icons icon, the way `Image(systemName:)`
/// shows an SF Symbol.
///
/// It draws in the foreground style and is labeled with the brand's name
/// for VoiceOver:
///
/// ```swift
/// Label {
///     Text("Built with Swift")
/// } icon: {
///     SimpleIconView(.swift)
/// }
///
/// SimpleIconView(.github)
///     .foregroundStyle(Color(simpleIcon: .github))
///     .frame(width: 44, height: 44)
/// ```
public struct SimpleIconView: View {
    // Only what the view reads, the path and the title, so SwiftUI compares
    // two strings to decide whether to draw again, not the whole icon.
    private let shape: SimpleIconShape
    private let title: String

    /// Creates a view that shows an icon.
    public init(_ icon: SimpleIcon) {
        shape = SimpleIconShape(icon)
        title = icon.title
    }

    /// The icon, square, labeled with the brand's name.
    public var body: some View {
        shape
            .aspectRatio(1, contentMode: .fit)
            .accessibilityElement()
            .accessibilityLabel(Text(verbatim: title))
            .accessibilityAddTraits(.isImage)
    }
}
#endif
