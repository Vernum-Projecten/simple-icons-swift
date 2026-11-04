/// An SVG path, as absolute drawing commands.
///
/// Parsing turns every command of the SVG path syntax into one of five
/// elements: relative coordinates become absolute, horizontal and vertical
/// lines become lines, smooth curves get their reflected control point, and
/// elliptical arcs become cubic Bézier curves. Drawing the elements in order,
/// with any 2D graphics API, draws the path.
///
/// ```swift
/// for element in SimpleIcon.swift.svgPath.elements {
///     switch element {
///     case .move(let point): context.move(to: point)
///     case .line(let point): context.addLine(to: point)
///     // …
///     }
/// }
/// ```
public struct SVGPath: Sendable, Hashable {
    /// The drawing commands, in order.
    public let elements: [Element]

    /// A drawing command with absolute coordinates.
    public enum Element: Sendable, Hashable {
        /// Starts a new subpath at a point.
        case move(to: Point)
        /// A straight line to a point.
        case line(to: Point)
        /// A quadratic Bézier curve to a point.
        case quadCurve(to: Point, control: Point)
        /// A cubic Bézier curve to a point.
        case curve(to: Point, control1: Point, control2: Point)
        /// A straight line back to the start of the subpath, closing it.
        case closeSubpath
    }

    /// A point in the path's coordinate space.
    public struct Point: Sendable, Hashable {
        /// The horizontal coordinate, growing to the right.
        public var x: Double
        /// The vertical coordinate, growing downward.
        public var y: Double

        /// Creates a point.
        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }

    /// Why path data could not be parsed.
    public struct ParseError: Error, Sendable, Hashable {
        /// The UTF-8 offset in the path data where parsing stopped.
        public let offset: Int
        /// The elements before the error, which an SVG renderer still draws.
        public let elementsBeforeError: [Element]
    }

    /// Creates a path from drawing commands.
    public init(elements: [Element]) {
        self.elements = elements
    }

    /// Parses SVG path data, the value of a `<path>` element's `d`
    /// attribute.
    ///
    /// - Parameter data: Path data such as `M0 0h24v24H0z`.
    /// - Throws: ``ParseError`` when the data does not follow the SVG path
    ///   grammar.
    public init(parsing data: String) throws(ParseError) {
        var parser = SVGPathParser(data)
        parser.parse()
        if let offset = parser.errorOffset {
            throw ParseError(offset: offset, elementsBeforeError: parser.elements)
        }
        elements = parser.elements
    }
}

extension SimpleIcon {
    /// The icon's ``path`` as drawing commands, in a 24 by 24 coordinate
    /// space with the origin at the top left.
    ///
    /// An icon made by hand whose path data has an error draws up to that
    /// error, as an SVG renderer does. Every icon in this package parses
    /// completely; the tests check each one.
    ///
    /// - Complexity: O(*n*) in the length of ``path``. The path is parsed on
    ///   every access, so keep the result when you draw it often.
    public var svgPath: SVGPath {
        var parser = SVGPathParser(path)
        parser.parse()
        return SVGPath(elements: parser.elements)
    }
}
