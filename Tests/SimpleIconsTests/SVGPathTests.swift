import SimpleIcons
import Testing

@Suite struct SVGPathTests {
    typealias Point = SVGPath.Point

    // MARK: - Every icon

    @Test(arguments: SimpleIcon.allCases)
    func `Every icon parses completely`(icon: SimpleIcon) throws {
        let path = try SVGPath(parsing: icon.path)
        #expect(!path.elements.isEmpty)
        #expect(path == icon.svgPath)
    }

    @Test(arguments: SimpleIcon.allCases)
    func `Every icon stays inside its 24 by 24 box`(icon: SimpleIcon) {
        // End points only: control points of a curve may lie outside.
        // Simple Icons keeps paths in the view box give or take rounding;
        // in 16.36.0 the furthest out is Python at x = 24.06. A parser
        // mistake (a relative point read as absolute, a lost sign) lands
        // far outside this margin.
        let tolerance = 0.1
        let range = -tolerance...(24 + tolerance)
        for element in icon.svgPath.elements {
            switch element {
            case .move(let point), .line(let point), .quadCurve(let point, _), .curve(let point, _, _):
                #expect(range.contains(point.x) && range.contains(point.y), "\(point)")
            case .closeSubpath:
                break
            }
        }
    }

    // MARK: - Commands

    @Test func `Relative coordinates become absolute`() throws {
        let path = try SVGPath(parsing: "m1 2l3 4h5v6z")
        #expect(
            path.elements == [
                .move(to: Point(x: 1, y: 2)),
                .line(to: Point(x: 4, y: 6)),
                .line(to: Point(x: 9, y: 6)),
                .line(to: Point(x: 9, y: 12)),
                .closeSubpath,
            ])
    }

    @Test func `Extra pairs after a moveto are linetos`() throws {
        let path = try SVGPath(parsing: "M0 0 1 1m1 1 1 1")
        #expect(
            path.elements == [
                .move(to: Point(x: 0, y: 0)),
                .line(to: Point(x: 1, y: 1)),
                .move(to: Point(x: 2, y: 2)),
                .line(to: Point(x: 3, y: 3)),
            ])
    }

    @Test func `Close returns the pen to the start of the subpath`() throws {
        let path = try SVGPath(parsing: "M2 2h4zl1 1")
        #expect(path.elements.last == .line(to: Point(x: 3, y: 3)))
    }

    @Test func `A smooth cubic mirrors the previous control point`() throws {
        let path = try SVGPath(parsing: "M0 0C1 1 2 1 3 0S5 -1 6 0")
        #expect(
            path.elements.last
                == .curve(
                    to: Point(x: 6, y: 0),
                    control1: Point(x: 4, y: -1),
                    control2: Point(x: 5, y: -1)
                ))
    }

    @Test func `A smooth cubic after a line starts at the pen`() throws {
        let path = try SVGPath(parsing: "M0 0L3 0s2 1 3 0")
        #expect(
            path.elements.last
                == .curve(
                    to: Point(x: 6, y: 0),
                    control1: Point(x: 3, y: 0),
                    control2: Point(x: 5, y: 1)
                ))
    }

    @Test func `A smooth quadratic mirrors the previous control point`() throws {
        let path = try SVGPath(parsing: "M0 0Q1 1 2 0T4 0")
        #expect(path.elements.last == .quadCurve(to: Point(x: 4, y: 0), control: Point(x: 3, y: -1)))
    }

    // MARK: - Numbers

    @Test(arguments: [
        ("M.5.5", Point(x: 0.5, y: 0.5)),
        ("M1-2", Point(x: 1, y: -2)),
        ("M1e1,2E-1", Point(x: 10, y: 0.2)),
        ("M 1 , 2", Point(x: 1, y: 2)),
        ("M+3-.25", Point(x: 3, y: -0.25)),
    ])
    func `Numbers end where the next one starts`(data: String, point: Point) throws {
        #expect(try SVGPath(parsing: data).elements == [.move(to: point)])
    }

    // MARK: - Arcs

    @Test func `Arc flags need no separator`() throws {
        let compact = try SVGPath(parsing: "M0 0a1 1 0 011 1")
        let spaced = try SVGPath(parsing: "M0 0a1 1 0 0 1 1 1")
        #expect(compact == spaced)
        #expect(compact.elements.count == 2)
    }

    @Test func `A half circle ends exactly at its end point`() throws {
        let path = try SVGPath(parsing: "M0 0A5 5 0 0 1 10 0")
        // 180 degrees: two quarter-circle curves.
        try #require(path.elements.count == 3)
        let end = try #require(Self.endPoint(ofCurve: path.elements[2]))
        #expect(end == Point(x: 10, y: 0))
        // The middle of the half circle, sweeping clockwise on screen, is
        // above the chord at (5, -5).
        let middle = try #require(Self.endPoint(ofCurve: path.elements[1]))
        #expect(abs(middle.x - 5) < 1e-9 && abs(middle.y + 5) < 1e-9)
    }

    /// Where a cubic curve ends, or `nil` for any other element.
    private static func endPoint(ofCurve element: SVGPath.Element) -> Point? {
        if case .curve(let end, _, _) = element { end } else { nil }
    }

    @Test func `Radii too small for the end points are scaled up`() throws {
        let path = try SVGPath(parsing: "M0 0A1 1 0 0 1 10 0")
        let scaled = try SVGPath(parsing: "M0 0A5 5 0 0 1 10 0")
        #expect(path.elements.count == scaled.elements.count)
    }

    @Test func `A zero radius draws a straight line`() throws {
        let path = try SVGPath(parsing: "M0 0A0 5 0 0 1 10 0")
        #expect(path.elements.last == .line(to: Point(x: 10, y: 0)))
    }

    @Test func `An arc to its own start point draws nothing`() throws {
        let path = try SVGPath(parsing: "M3 3A5 5 0 0 1 3 3")
        #expect(path.elements == [.move(to: Point(x: 3, y: 3))])
    }

    // MARK: - Errors

    @Test(arguments: [
        ("L1 1", 0),
        ("M1 1X", 4),
        ("M1 1L2", 6),
        ("M0 0a1 1 0 2 1 1 1", 11),
    ])
    func `Bad data stops where it goes wrong`(data: String, offset: Int) throws {
        let error = try #require(throws: SVGPath.ParseError.self) {
            try SVGPath(parsing: data)
        }
        #expect(error.offset == offset)
    }

    @Test func `What came before an error is kept`() throws {
        let error = try #require(throws: SVGPath.ParseError.self) {
            try SVGPath(parsing: "M1 1L2 2X")
        }
        #expect(error.elementsBeforeError == [.move(to: Point(x: 1, y: 1)), .line(to: Point(x: 2, y: 2))])
    }

    @Test func `Empty data is an empty path`() throws {
        #expect(try SVGPath(parsing: "").elements.isEmpty)
        #expect(try SVGPath(parsing: "  ").elements.isEmpty)
    }
}
