internal import Foundation

/// Reads SVG path data into absolute ``SVGPath/Element``s, following the
/// grammar in SVG 2, section 9.3.9 ("The grammar for path data").
///
/// On an error it stops and keeps the elements read so far, which is what
/// an SVG renderer draws (SVG 2, section 9.5.4, "Error handling in path
/// data").
struct SVGPathParser {
    typealias Point = SVGPath.Point

    private(set) var elements: [SVGPath.Element] = []
    /// The UTF-8 offset where parsing stopped, or `nil` when it read all.
    private(set) var errorOffset: Int?

    private let bytes: [UInt8]
    private var index = 0

    /// Where the pen is.
    private var current = Point(x: 0, y: 0)
    /// Where the current subpath started, for `Z`.
    private var subpathStart = Point(x: 0, y: 0)
    /// The second control point of the last cubic curve, for `S`.
    private var lastCubicControl: Point?
    /// The control point of the last quadratic curve, for `T`.
    private var lastQuadControl: Point?

    init(_ data: String) {
        bytes = Array(data.utf8)
    }

    mutating func parse() {
        skipSeparators()
        // Path data that is not empty starts with a moveto.
        if index < bytes.count, bytes[index] != UInt8(ascii: "M"), bytes[index] != UInt8(ascii: "m") {
            errorOffset = index
            return
        }
        while index < bytes.count {
            let command = bytes[index]
            index += 1
            guard readCommand(command) else {
                errorOffset = index
                return
            }
            skipSeparators()
        }
    }

    // MARK: - Commands

    /// Reads the arguments of one command letter, repeated as long as
    /// numbers follow. Returns `false` on an error.
    private mutating func readCommand(_ command: UInt8) -> Bool {
        let relative = command >= UInt8(ascii: "a")
        switch command | 0x20 {  // lowercase
        case UInt8(ascii: "z"):
            elements.append(.closeSubpath)
            current = subpathStart
            lastCubicControl = nil
            lastQuadControl = nil
            return true
        case UInt8(ascii: "m"):
            // A moveto's extra coordinate pairs are implicit linetos.
            guard let point = readPoint(relative: relative) else { return false }
            elements.append(.move(to: point))
            current = point
            subpathStart = point
            resetControls()
            return repeatWhileNumbers {
                guard let point = $0.readPoint(relative: relative) else { return false }
                $0.lineTo(point)
                return true
            }
        case UInt8(ascii: "l"):
            return repeatAtLeastOnce {
                guard let point = $0.readPoint(relative: relative) else { return false }
                $0.lineTo(point)
                return true
            }
        case UInt8(ascii: "h"):
            return repeatAtLeastOnce {
                guard let x = $0.readNumber() else { return false }
                $0.lineTo(Point(x: relative ? $0.current.x + x : x, y: $0.current.y))
                return true
            }
        case UInt8(ascii: "v"):
            return repeatAtLeastOnce {
                guard let y = $0.readNumber() else { return false }
                $0.lineTo(Point(x: $0.current.x, y: relative ? $0.current.y + y : y))
                return true
            }
        case UInt8(ascii: "c"):
            return repeatAtLeastOnce {
                guard let control1 = $0.readPoint(relative: relative),
                    let control2 = $0.readPoint(relative: relative),
                    let point = $0.readPoint(relative: relative)
                else { return false }
                $0.curveTo(point, control1: control1, control2: control2)
                return true
            }
        case UInt8(ascii: "s"):
            return repeatAtLeastOnce { parser in
                // The first control point mirrors the last curve's second
                // one, or is the pen when the last command was no C or S.
                let pen = parser.current
                let control1 = parser.lastCubicControl?.reflected(through: pen) ?? pen
                guard let control2 = parser.readPoint(relative: relative),
                    let point = parser.readPoint(relative: relative)
                else { return false }
                parser.curveTo(point, control1: control1, control2: control2)
                return true
            }
        case UInt8(ascii: "q"):
            return repeatAtLeastOnce {
                guard let control = $0.readPoint(relative: relative),
                    let point = $0.readPoint(relative: relative)
                else { return false }
                $0.quadTo(point, control: control)
                return true
            }
        case UInt8(ascii: "t"):
            return repeatAtLeastOnce { parser in
                let pen = parser.current
                let control = parser.lastQuadControl?.reflected(through: pen) ?? pen
                guard let point = parser.readPoint(relative: relative) else { return false }
                parser.quadTo(point, control: control)
                return true
            }
        case UInt8(ascii: "a"):
            return repeatAtLeastOnce {
                guard let rx = $0.readNumber(),
                    let ry = $0.readNumber(),
                    let rotation = $0.readNumber(),
                    let largeArc = $0.readFlag(),
                    let sweep = $0.readFlag(),
                    let point = $0.readPoint(relative: relative)
                else { return false }
                $0.arcTo(point, radii: (rx, ry), rotation: rotation, largeArc: largeArc, sweep: sweep)
                return true
            }
        default:
            index -= 1
            return false
        }
    }

    /// Runs `body` once, then again for as long as a number follows.
    private mutating func repeatAtLeastOnce(_ body: (inout Self) -> Bool) -> Bool {
        guard body(&self) else { return false }
        return repeatWhileNumbers(body)
    }

    /// Runs `body` for as long as a number follows.
    private mutating func repeatWhileNumbers(_ body: (inout Self) -> Bool) -> Bool {
        skipSeparators()
        while startsNumber() {
            guard body(&self) else { return false }
            skipSeparators()
        }
        return true
    }

    // MARK: - Drawing

    private mutating func resetControls() {
        lastCubicControl = nil
        lastQuadControl = nil
    }

    private mutating func lineTo(_ point: Point) {
        elements.append(.line(to: point))
        current = point
        resetControls()
    }

    private mutating func curveTo(_ point: Point, control1: Point, control2: Point) {
        elements.append(.curve(to: point, control1: control1, control2: control2))
        current = point
        lastCubicControl = control2
        lastQuadControl = nil
    }

    private mutating func quadTo(_ point: Point, control: Point) {
        elements.append(.quadCurve(to: point, control: control))
        current = point
        lastQuadControl = control
        lastCubicControl = nil
    }

    private mutating func arcTo(
        _ point: Point,
        radii: (Double, Double),
        rotation: Double,
        largeArc: Bool,
        sweep: Bool
    ) {
        let curves = SVGArc.cubicCurves(
            from: current,
            to: point,
            radii: radii,
            rotation: rotation,
            largeArc: largeArc,
            sweep: sweep
        )
        if curves.isEmpty {
            // Zero radii: SVG draws a straight line (SVG 2, B.2.5).
            if current != point { elements.append(.line(to: point)) }
        } else {
            for curve in curves {
                elements.append(.curve(to: curve.to, control1: curve.control1, control2: curve.control2))
            }
        }
        current = point
        resetControls()
    }

    // MARK: - Tokens

    private mutating func readPoint(relative: Bool) -> Point? {
        guard let x = readNumber(), let y = readNumber() else { return nil }
        return relative ? Point(x: current.x + x, y: current.y + y) : Point(x: x, y: y)
    }

    /// Skips white space and at most one comma.
    private mutating func skipSeparators() {
        skipWhitespace()
        if index < bytes.count, bytes[index] == UInt8(ascii: ",") {
            index += 1
            skipWhitespace()
        }
    }

    private mutating func skipWhitespace() {
        while index < bytes.count, Self.isWhitespace(bytes[index]) { index += 1 }
    }

    private static func isWhitespace(_ byte: UInt8) -> Bool {
        byte == 0x20 || byte == 0x09 || byte == 0x0A || byte == 0x0C || byte == 0x0D
    }

    private static func isDigit(_ byte: UInt8) -> Bool {
        byte >= UInt8(ascii: "0") && byte <= UInt8(ascii: "9")
    }

    private func startsNumber() -> Bool {
        guard index < bytes.count else { return false }
        let byte = bytes[index]
        return Self.isDigit(byte) || byte == UInt8(ascii: "-") || byte == UInt8(ascii: "+")
            || byte == UInt8(ascii: ".")
    }

    /// Reads a number and the separator after it. A number ends where the
    /// next one starts, so `.5.5` is two numbers and `1-2` is `1` and `-2`.
    private mutating func readNumber() -> Double? {
        skipSeparators()
        let start = index
        if index < bytes.count, bytes[index] == UInt8(ascii: "-") || bytes[index] == UInt8(ascii: "+") {
            index += 1
        }
        var digits = 0
        while index < bytes.count, Self.isDigit(bytes[index]) {
            index += 1
            digits += 1
        }
        if index < bytes.count, bytes[index] == UInt8(ascii: ".") {
            index += 1
            while index < bytes.count, Self.isDigit(bytes[index]) {
                index += 1
                digits += 1
            }
        }
        guard digits > 0 else {
            index = start
            return nil
        }
        // An exponent only when digits follow it.
        if index < bytes.count, bytes[index] | 0x20 == UInt8(ascii: "e") {
            var probe = index + 1
            if probe < bytes.count, bytes[probe] == UInt8(ascii: "-") || bytes[probe] == UInt8(ascii: "+") {
                probe += 1
            }
            if probe < bytes.count, Self.isDigit(bytes[probe]) {
                index = probe
                while index < bytes.count, Self.isDigit(bytes[index]) { index += 1 }
            }
        }
        let text = String(decoding: bytes[start..<index], as: UTF8.self)
        guard let value = Double(text), value.isFinite else {
            index = start
            return nil
        }
        skipSeparators()
        return value
    }

    /// Reads an arc flag: a single `0` or `1`, which needs no separator
    /// after it (`a1 1 0 011 1` has the flags `0` and `1`).
    private mutating func readFlag() -> Bool? {
        skipSeparators()
        guard index < bytes.count else { return nil }
        let byte = bytes[index]
        guard byte == UInt8(ascii: "0") || byte == UInt8(ascii: "1") else { return nil }
        index += 1
        skipSeparators()
        return byte == UInt8(ascii: "1")
    }
}

extension SVGPath.Point {
    /// This point mirrored through another one.
    func reflected(through center: Self) -> Self {
        Self(x: 2 * center.x - x, y: 2 * center.y - y)
    }
}
