internal import Foundation

/// Turns an SVG elliptical arc into cubic Bézier curves.
///
/// Follows the SVG 2 implementation notes: B.2.4 converts the arc from its
/// endpoints to its center, and B.2.5 corrects radii that are too small or
/// zero. The arc is then cut into pieces of at most 90 degrees, each drawn
/// with the usual cubic approximation, which stays within 0.03% of the
/// ellipse.
enum SVGArc {
    typealias Point = SVGPath.Point

    struct Curve: Equatable {
        var control1: Point
        var control2: Point
        var to: Point
    }

    /// The curves that draw the arc, or none when the endpoints are equal
    /// (SVG then omits the arc) or a radius is zero (SVG then draws a line).
    static func cubicCurves(
        from start: Point,
        to end: Point,
        radii: (Double, Double),
        rotation degrees: Double,
        largeArc: Bool,
        sweep: Bool
    ) -> [Curve] {
        if start == end { return [] }
        var rx = abs(radii.0)
        var ry = abs(radii.1)
        if rx == 0 || ry == 0 { return [] }

        let phi = degrees.truncatingRemainder(dividingBy: 360) * .pi / 180
        let cosPhi = cos(phi)
        let sinPhi = sin(phi)

        // Step 1: the start point in the ellipse's own axes, centered
        // between the endpoints.
        let dx = (start.x - end.x) / 2
        let dy = (start.y - end.y) / 2
        let x1 = cosPhi * dx + sinPhi * dy
        let y1 = -sinPhi * dx + cosPhi * dy

        // B.2.5: scale radii up that cannot reach both endpoints.
        let lambda = (x1 * x1) / (rx * rx) + (y1 * y1) / (ry * ry)
        if lambda > 1 {
            let scale = lambda.squareRoot()
            rx *= scale
            ry *= scale
        }

        // Step 2: the center in the ellipse's axes.
        let rx2 = rx * rx
        let ry2 = ry * ry
        let numerator = rx2 * ry2 - rx2 * y1 * y1 - ry2 * x1 * x1
        let denominator = rx2 * y1 * y1 + ry2 * x1 * x1
        var coefficient = (max(0, numerator / denominator)).squareRoot()
        if largeArc == sweep { coefficient = -coefficient }
        let cx1 = coefficient * rx * y1 / ry
        let cy1 = -coefficient * ry * x1 / rx

        // Step 3: the center in user space.
        let cx = cosPhi * cx1 - sinPhi * cy1 + (start.x + end.x) / 2
        let cy = sinPhi * cx1 + cosPhi * cy1 + (start.y + end.y) / 2

        // Step 4: the start angle and the angle the arc sweeps.
        let theta1 = angle(from: (1, 0), to: ((x1 - cx1) / rx, (y1 - cy1) / ry))
        var delta = angle(
            from: ((x1 - cx1) / rx, (y1 - cy1) / ry),
            to: ((-x1 - cx1) / rx, (-y1 - cy1) / ry)
        )
        if !sweep, delta > 0 { delta -= 2 * .pi }
        if sweep, delta < 0 { delta += 2 * .pi }

        // A point on the unit circle, mapped onto the ellipse.
        func onEllipse(_ ux: Double, _ uy: Double) -> Point {
            Point(
                x: cx + rx * ux * cosPhi - ry * uy * sinPhi,
                y: cy + rx * ux * sinPhi + ry * uy * cosPhi
            )
        }

        let segments = max(1, Int((abs(delta) / (.pi / 2)).rounded(.up)))
        let step = delta / Double(segments)
        // The distance of a quarter circle's control points from its ends,
        // for an arc of `step` radians.
        let handle = 4.0 / 3.0 * tan(step / 4)

        var curves: [Curve] = []
        curves.reserveCapacity(segments)
        for segment in 0..<segments {
            let a1 = theta1 + Double(segment) * step
            let a2 = a1 + step
            let (cos1, sin1) = (cos(a1), sin(a1))
            let (cos2, sin2) = (cos(a2), sin(a2))
            curves.append(
                Curve(
                    control1: onEllipse(cos1 - handle * sin1, sin1 + handle * cos1),
                    control2: onEllipse(cos2 + handle * sin2, sin2 - handle * cos2),
                    // The last piece ends exactly where the arc does, so no
                    // rounding error opens a gap.
                    to: segment == segments - 1 ? end : onEllipse(cos2, sin2)
                )
            )
        }
        return curves
    }

    /// The signed angle from one vector to another, in radians.
    private static func angle(from u: (Double, Double), to v: (Double, Double)) -> Double {
        atan2(u.0 * v.1 - u.1 * v.0, u.0 * v.0 + u.1 * v.1)
    }
}
