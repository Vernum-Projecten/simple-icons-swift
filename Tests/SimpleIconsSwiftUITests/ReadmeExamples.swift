#if canImport(SwiftUI)
// The code of the README's examples, so CI compiles each one: when the API
// changes, this file and the README change together.

import SimpleIcons
import SimpleIconsSwiftUI
import SwiftUI
import Testing

// MARK: - SwiftUI

private struct BuiltWithSwift: View {
    var body: some View {
        Label {
            Text("Built with Swift")
        } icon: {
            SimpleIconView(.swift)
        }
    }
}

private struct SignInButtons: View {
    var body: some View {
        HStack(spacing: 16) {
            SimpleIconView(.github)
                .foregroundStyle(Color(simpleIcon: .github))
                .frame(width: 44, height: 44)

            SimpleIconView(.apple)
                .frame(width: 44, height: 44)
        }
    }
}

private struct OutlinedLogo: View {
    var body: some View {
        SimpleIconShape(.figma)
            .stroke(Color(simpleIcon: .figma), lineWidth: 0.5)
            .frame(width: 120, height: 120)
    }
}

private struct AllIcons: View {
    private static let icons = SimpleIcon.allCases

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))]) {
                ForEach(Self.icons) { icon in
                    SimpleIconView(icon)
                        .foregroundStyle(Color(simpleIcon: icon))
                        .frame(width: 32, height: 32)
                        .help(icon.title)
                }
            }
        }
    }
}

// MARK: - Without SwiftUI

@Suite struct ReadmeExamples {
    @Test func `Metadata`() {
        let icon = SimpleIcon.swift
        _ = icon.title  // "Swift"
        _ = icon.hex  // "F05138"
        _ = icon.source  // where the icon comes from

        switch icon.license {
        case .spdx(let identifier): _ = identifier  // such as "CC0-1.0"
        case .custom(let url): _ = url  // the brand's own terms
        case .unknown: break  // Simple Icons has no license data
        }

        if case .url(let url) = icon.guidelines {
            _ = url  // the brand's rules for using its logo
        }
    }

    @Test func `SVG`() {
        let svg = SimpleIcon.swift.svg  // exactly the file Simple Icons publishes
        let white = SimpleIcon.swift.svg(fill: "white")
        let brand = SimpleIcon.swift.svg(fill: "#\(SimpleIcon.swift.hex)")
        #expect(!svg.isEmpty && !white.isEmpty && !brand.isEmpty)
    }

    @Test func `Names that are not plain Swift names`() {
        let names = [SimpleIcon.`1password`, .`await`, .dotnet, .nodedotjs]
        #expect(names.count == 4)
    }

    @Test func `Core Graphics`() {
        let path: CGPath = Path(SimpleIcon.swift).cgPath  // 24 by 24 points
        #expect(!path.isEmpty)
    }

    @Test func `Any graphics API`() {
        var commands = 0
        for element in SimpleIcon.swift.svgPath.elements {
            switch element {
            case .move(let point): _ = point
            case .line(let point): _ = point
            case .quadCurve(let point, let control): _ = (point, control)
            case .curve(let point, let control1, let control2): _ = (point, control1, control2)
            case .closeSubpath: break
            }
            commands += 1
        }
        #expect(commands > 0)
    }

    @Test func `Search`() {
        let matches = SimpleIcon.allCases.filter { $0.title.localizedStandardContains("git") }
        #expect(matches.contains(.github))
    }

    @MainActor @Test func `The views build`() {
        _ = BuiltWithSwift().body
        _ = SignInButtons().body
        _ = OutlinedLogo().body
        _ = AllIcons().body
    }
}
#endif
