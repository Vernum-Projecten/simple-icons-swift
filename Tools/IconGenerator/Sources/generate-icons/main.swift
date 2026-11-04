// generate-icons <npm-package-dir> <output-dir>
//
// Reads an unpacked simple-icons npm package (data/simple-icons.json,
// icons/<slug>.svg, package.json) and writes one Swift file per first
// letter of the slug, plus the list of every icon and the version, into
// <output-dir>, which it empties first.
//
// It refuses to write anything when an SVG file is not exactly what
// SimpleIcon.svg rebuilds from the title and the path, or when a slug
// would not make a valid, unambiguous Swift name: the package then cannot
// keep its promise that `svg` is the upstream file byte for byte.

import Foundation

// MARK: - Input

struct Icon: Decodable {
    struct License: Decodable {
        let type: String
        let url: String?
    }

    struct Aliases: Decodable {
        let aka: [String]?
        let dup: [Duplicate]?
        let loc: [String: String]?
        let old: [String]?
    }

    struct Duplicate: Decodable {
        let title: String
        let hex: String?
        let source: String?
        let guidelines: String?
    }

    let title: String
    let slug: String
    let hex: String
    let source: String
    let guidelines: String?
    let license: License?
    let aliases: Aliases?
}

struct NPMPackage: Decodable {
    let version: String
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("generate-icons: \(message)\n".utf8))
    exit(1)
}

let arguments = CommandLine.arguments
guard arguments.count == 3 else {
    fail("usage: generate-icons <npm-package-dir> <output-dir>")
}
let packageDirectory = URL(fileURLWithPath: arguments[1], isDirectory: true)
let outputDirectory = URL(fileURLWithPath: arguments[2], isDirectory: true)

func read(_ relativePath: String) -> Data {
    let url = packageDirectory.appendingPathComponent(relativePath)
    guard let data = try? Data(contentsOf: url) else { fail("cannot read \(url.path)") }
    return data
}

let version: String
let icons: [Icon]
do {
    version = try JSONDecoder().decode(NPMPackage.self, from: read("package.json")).version
    icons = try JSONDecoder().decode([Icon].self, from: read("data/simple-icons.json"))
} catch {
    fail("cannot decode the package: \(error)")
}

// MARK: - Checks

/// The same escaping as SimpleIcon.xmlEscaped(_:quotes: false) in the
/// library; the check below proves both agree with every upstream file.
func xmlEscaped(_ text: String) -> String {
    var escaped = ""
    for scalar in text.unicodeScalars {
        switch scalar {
        case "&": escaped += "&amp;"
        case "<": escaped += "&lt;"
        case ">": escaped += "&gt;"
        case _ where scalar.isASCII: escaped.unicodeScalars.append(scalar)
        default: escaped += "&#\(scalar.value);"
        }
    }
    return escaped
}

let svgPrefix = "<svg role=\"img\" viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><title>"

/// The path data of an icon's SVG file, after checking that the file is
/// exactly what SimpleIcon.svg rebuilds.
func pathData(of icon: Icon) -> String {
    let file = String(decoding: read("icons/\(icon.slug).svg"), as: UTF8.self)
    let head = svgPrefix + xmlEscaped(icon.title) + "</title><path d=\""
    let tail = "\"/></svg>"
    guard file.hasPrefix(head), file.hasSuffix(tail), file.count > head.count + tail.count else {
        fail(
            "icons/\(icon.slug).svg is not the SVG that SimpleIcon.svg rebuilds; update SimpleIcon+SVG.swift and this generator together"
        )
    }
    let path = String(file.dropFirst(head.count).dropLast(tail.count))
    guard !path.contains("\"") else { fail("icons/\(icon.slug).svg has more than one path") }
    return path
}

/// Words Swift reserves somewhere; a slug that is one gets backticks.
/// Backticks around any other name are harmless, so the list errs wide.
let keywords: Set<String> = [
    "associatedtype", "borrowing", "class", "consuming", "deinit", "enum", "extension",
    "fileprivate", "func", "import", "init", "inout", "internal", "let", "nonisolated",
    "open", "operator", "private", "precedencegroup", "protocol", "public", "rethrows",
    "static", "struct", "subscript", "typealias", "var", "break", "case", "catch",
    "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if",
    "in", "repeat", "return", "throw", "switch", "where", "while", "any", "as", "await",
    "false", "is", "nil", "self", "super", "throws", "true", "try", "async", "some",
    "package", "actor", "macro", "each", "copy", "discard", "then",
]

/// Names a slug may not take, because SimpleIcon already has a static
/// member of that name or Swift gives it a meaning on every type.
let takenNames: Set<String> = ["allcases", "self", "type", "protocol", "init", "simpleiconsversion"]

func swiftName(for slug: String) -> String {
    // Simple Icons slugs are lowercase letters and digits, with an
    // underscore before a suffix that tells two brands apart
    // (`backstage_casting`). All of that is valid in a Swift name.
    guard let first = slug.first, first != "_",
        slug.allSatisfy({ $0.isASCII && ($0.isLowercase || $0.isNumber || $0 == "_") })
    else {
        fail("slug '\(slug)' is not lowercase ASCII letters, digits and underscores; the naming rule needs a change")
    }
    guard !takenNames.contains(slug) else { fail("slug '\(slug)' would clash with a member of SimpleIcon") }
    // A digit first needs a raw identifier (SE-0451), as does a keyword.
    if first.isNumber || keywords.contains(slug) { return "`\(slug)`" }
    return slug
}

// MARK: - Output

/// A Swift string literal.
func literal(_ text: String) -> String {
    var escaped = ""
    for scalar in text.unicodeScalars {
        switch scalar {
        case "\\": escaped += "\\\\"
        case "\"": escaped += "\\\""
        case "\n": escaped += "\\n"
        case "\r": escaped += "\\r"
        case "\t": escaped += "\\t"
        case _ where scalar.value < 0x20: escaped += "\\u{\(String(scalar.value, radix: 16))}"
        default: escaped.unicodeScalars.append(scalar)
        }
    }
    return "\"\(escaped)\""
}

func literal(_ list: [String]) -> String {
    "[" + list.map { literal($0) }.joined(separator: ", ") + "]"
}

/// `.url("…")`, or `nil` when the brand has no guidelines, so the argument
/// is left out and takes its default, `.unknown`.
func guidelinesLiteral(_ address: String?) -> String? {
    address.map { ".url(\(literal($0)))" }
}

/// The License case for the upstream `{type, url}`. Upstream has two shapes:
/// an SPDX identifier without an address, and `custom` with one. Anything
/// else stops the generator, so a new shape is modeled, not guessed.
func licenseLiteral(_ license: Icon.License, slug: String) -> String {
    switch (license.type, license.url) {
    case ("custom", let url?):
        return ".custom(url: \(literal(url)))"
    case ("custom", nil):
        fail("\(slug) has a custom license without an address; SimpleIcon.License needs a case for it")
    case (let type, nil):
        return ".spdx(\(literal(type)))"
    case (let type, _?):
        fail("\(slug) has the SPDX license \(type) with an address; SimpleIcon.License needs a case for it")
    }
}

func aliasesLiteral(_ aliases: Icon.Aliases, of icon: Icon) -> String {
    var parts: [String] = []
    if let aka = aliases.aka { parts.append("alsoKnownAs: \(literal(aka))") }
    if let dup = aliases.dup {
        // What a duplicate leaves out, it shares with the main brand.
        let list = dup.map { duplicate in
            var arguments = [
                "title: \(literal(duplicate.title))",
                "hex: \(literal(duplicate.hex ?? icon.hex))",
                "source: \(literal(duplicate.source ?? icon.source))",
            ]
            if let guidelines = guidelinesLiteral(duplicate.guidelines ?? icon.guidelines) {
                arguments.append("guidelines: \(guidelines)")
            }
            return "Duplicate(\(arguments.joined(separator: ", ")))"
        }
        parts.append("duplicates: [\(list.joined(separator: ", "))]")
    }
    if let loc = aliases.loc {
        let pairs = loc.sorted { $0.key < $1.key }.map { "\(literal($0.key)): \(literal($0.value))" }
        parts.append("localizedTitles: [\(pairs.joined(separator: ", "))]")
    }
    if let old = aliases.old { parts.append("formerTitles: \(literal(old))") }
    return "Aliases(\(parts.joined(separator: ", ")))"
}

func arguments(for icon: Icon, path: String) -> [String] {
    var lines = [
        "title: \(literal(icon.title))",
        "slug: \(literal(icon.slug))",
        "hex: \(literal(icon.hex))",
        "source: \(literal(icon.source))",
    ]
    if let guidelines = guidelinesLiteral(icon.guidelines) {
        lines.append("guidelines: \(guidelines)")
    }
    if let license = icon.license {
        lines.append("license: \(licenseLiteral(license, slug: icon.slug))")
    }
    if let aliases = icon.aliases {
        lines.append("aliases: \(aliasesLiteral(aliases, of: icon))")
    }
    lines.append("path: \(literal(path))")
    return lines
}

let header = """
    // Generated by Tools/IconGenerator from simple-icons \(version).
    // Do not edit: run scripts/dev/update-icons.sh instead.

    """

/// The file an icon goes in: one per first letter, one for digits.
/// `swiftName(for:)` has already refused an empty slug.
func fileGroup(for slug: String) -> String {
    guard let first = slug.first, !first.isNumber else { return "Digits" }
    return first.uppercased()
}

var groups: [String: [String]] = [:]
var seen: Set<String> = []
var names: [String] = []
for icon in icons {
    guard seen.insert(icon.slug).inserted else { fail("slug '\(icon.slug)' appears twice") }
    guard icon.hex.count == 6, icon.hex.allSatisfy(\.isHexDigit) else {
        fail("\(icon.slug) has hex '\(icon.hex)', not six hexadecimal digits")
    }
    let name = swiftName(for: icon.slug)
    names.append(name)
    let path = pathData(of: icon)
    let body = arguments(for: icon, path: path).map { "        \($0)" }.joined(separator: ",\n")
    let declaration = """
            /// The \(icon.title) icon, brand color `#\(icon.hex)`.
            public static let \(name) = SimpleIcon(
        \(body)
            )
        """
    groups[fileGroup(for: icon.slug), default: []].append(declaration)
}

let fileManager = FileManager.default
try? fileManager.removeItem(at: outputDirectory)
do {
    try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
} catch {
    fail("cannot create \(outputDirectory.path): \(error)")
}

func write(_ name: String, _ contents: String) {
    let url = outputDirectory.appendingPathComponent(name)
    do {
        try Data(contents.utf8).write(to: url, options: .atomic)
    } catch {
        fail("cannot write \(url.path): \(error)")
    }
}

for (group, declarations) in groups {
    write(
        "SimpleIcon+\(group).swift",
        header + "\nextension SimpleIcon {\n" + declarations.joined(separator: "\n\n") + "\n}\n"
    )
}

write(
    "SimpleIcon+AllCases.swift",
    header + """

        extension SimpleIcon {
            /// Every icon in Simple Icons, in its order: by title.
            public static let allCases: [SimpleIcon] = [
        \(names.map { "        .\($0)," }.joined(separator: "\n"))
            ]

            /// The version of Simple Icons these icons come from.
            public static let simpleIconsVersion = \(literal(version))
        }

        """
)

print("generate-icons: \(icons.count) icons from simple-icons \(version) in \(groups.count + 1) files.")
