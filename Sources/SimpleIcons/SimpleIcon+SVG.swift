extension SimpleIcon {
    /// The icon as an SVG document, byte for byte the file Simple Icons
    /// publishes.
    ///
    /// The path has no fill, so it draws in the default color, black. Use
    /// ``svg(fill:)`` for another color.
    public var svg: String {
        makeSVG(attributes: "")
    }

    /// The icon as an SVG document that draws in a color.
    ///
    /// ```swift
    /// SimpleIcon.swift().svg(fill: "#\(SimpleIcon.swift().hex)")  // brand color
    /// SimpleIcon.swift().svg(fill: "currentColor")             // CSS text color
    /// ```
    ///
    /// - Parameter fill: Any SVG paint value, such as `#F05138`, `white`
    ///   or `currentColor`. It is escaped for the attribute.
    /// - Returns: The SVG document with `fill` set on its root element.
    public func svg(fill: String) -> String {
        makeSVG(attributes: " fill=\"\(Self.xmlEscaped(fill, quotes: true))\"")
    }

    private func makeSVG(attributes: String) -> String {
        "<svg role=\"img\" viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"\(attributes)>"
            + "<title>\(Self.xmlEscaped(title, quotes: false))</title>"
            + "<path d=\"\(path)\"/></svg>"
    }

    /// Escapes text the way Simple Icons' SVG files do: `&`, `<` and `>` as
    /// named entities and everything outside ASCII as a decimal character
    /// reference (`Aldi Süd` becomes `Aldi S&#252;d`). Quotes stay as they
    /// are in element text (`Byju's`) and are escaped in an attribute.
    static func xmlEscaped(_ text: String, quotes: Bool) -> String {
        var escaped = ""
        escaped.reserveCapacity(text.utf8.count)
        for scalar in text.unicodeScalars {
            switch scalar {
            case "&": escaped += "&amp;"
            case "<": escaped += "&lt;"
            case ">": escaped += "&gt;"
            case "\"" where quotes: escaped += "&quot;"
            case "'" where quotes: escaped += "&apos;"
            case _ where scalar.isASCII: escaped.unicodeScalars.append(scalar)
            default: escaped += "&#\(scalar.value);"
            }
        }
        return escaped
    }
}
