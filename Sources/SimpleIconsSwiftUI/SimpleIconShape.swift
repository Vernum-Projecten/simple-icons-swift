#if canImport(SwiftUI)
public import SwiftUI
public import SimpleIcons

/// A shape that draws a Simple Icons icon, scaled to fit its frame.
///
/// Like any shape it fills with the foreground style, so it takes the
/// color you give it:
///
/// ```swift
/// SimpleIconShape(.swift())
///     .fill(Color(simpleIcon: .swift()))
///     .frame(width: 32, height: 32)
/// ```
///
/// The icon keeps its square proportions and is centered in a frame that
/// is not square. Use ``SimpleIconView`` for an icon with an accessibility
/// label.
public struct SimpleIconShape: Shape {
    /// The SVG path data, the only part of the icon the shape reads, so
    /// SwiftUI compares a short string to decide whether to draw again.
    private let pathData: String

    /// Creates a shape that draws an icon.
    public init(_ icon: SimpleIcon) {
        pathData = icon.path
    }

    /// The icon, as large as fits in `rect` and centered in it.
    public func path(in rect: CGRect) -> Path {
        let side = min(rect.width, rect.height)
        let scale = side / 24
        let transform = CGAffineTransform(
            translationX: rect.minX + (rect.width - side) / 2,
            y: rect.minY + (rect.height - side) / 2
        )
        .scaledBy(x: scale, y: scale)
        return Path(svgPathData: pathData).applying(transform)
    }

    /// A square as large as the proposal allows, 24 points when the
    /// proposal leaves the size open.
    public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        // Square, as large as the proposal allows.
        let side = min(proposal.width ?? 24, proposal.height ?? 24)
        return CGSize(width: side, height: side)
    }
}

extension Path {
    /// Creates a path that draws an icon in its own 24 by 24 coordinate
    /// space, with the origin at the top left.
    public init(_ icon: SimpleIcon) {
        self.init(svgPathData: icon.path)
    }

    /// Creates a path from drawing commands.
    public init(_ svgPath: SVGPath) {
        self.init()
        for element in svgPath.elements {
            switch element {
            case .move(let point):
                move(to: CGPoint(point))
            case .line(let point):
                addLine(to: CGPoint(point))
            case .quadCurve(let point, let control):
                addQuadCurve(to: CGPoint(point), control: CGPoint(control))
            case .curve(let point, let control1, let control2):
                addCurve(to: CGPoint(point), control1: CGPoint(control1), control2: CGPoint(control2))
            case .closeSubpath:
                closeSubpath()
            }
        }
    }

    /// A path from SVG path data, drawn up to the first error as SVG does.
    init(svgPathData: String) {
        do {
            try self.init(SVGPath(parsing: svgPathData))
        } catch {
            self.init(SVGPath(elements: error.elementsBeforeError))
        }
    }
}

extension CGPoint {
    init(_ point: SVGPath.Point) {
        self.init(x: point.x, y: point.y)
    }
}
#endif
