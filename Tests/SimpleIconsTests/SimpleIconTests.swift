import Foundation
import SimpleIcons
import Testing

@Suite struct SimpleIconTests {
    @Test func `An icon is a typed constant`() {
        let icon = SimpleIcon.swift()
        #expect(icon.title == "Swift")
        #expect(icon.slug == "swift")
        #expect(icon.hex == "F05138")
    }

    @Test func `Slugs that are not plain Swift names work with backticks`() {
        #expect(SimpleIcon.`1password`().slug == "1password")
        #expect(SimpleIcon.`await`().slug == "await")
        #expect(SimpleIcon.svg().slug == "svg")
        #expect(SimpleIcon.backstage_casting().slug == "backstage_casting")
    }

    @Test func `allCases works on a thread with a small stack`() async {
        // A detached task runs on the cooperative pool, whose threads have a
        // 512 KB stack. Built as one array literal, allCases needed more in a
        // debug build and crashed there; it is built in parts now.
        let count = await Task.detached { SimpleIcon.allCases.count }.value
        #expect(count == SimpleIcon.allCases.count)
        #expect(count > 3_000)
    }

    @Test func `Every slug is unique`() {
        let slugs = SimpleIcon.allCases.map(\.slug)
        #expect(Set(slugs).count == slugs.count)
    }

    @Test func `Every brand color is six uppercase hexadecimal digits`() {
        let colors =
            SimpleIcon.allCases.map(\.hex)
            + SimpleIcon.allCases.flatMap { $0.aliases.duplicates.map(\.hex) }
        let invalid = colors.filter { hex in
            hex.count != 6 || !hex.allSatisfy { $0.isNumber || ("A"..."F").contains($0) }
        }
        #expect(invalid.isEmpty, "\(invalid)")
    }

    @Test func `The version is the one simple-icons.json pins`() throws {
        // The test file sits in Tests/SimpleIconsTests/; the pin at the root.
        let pin = URL(filePath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: "simple-icons.json")
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: pin)) as? [String: Any]
        let pinned = try #require(json?["simpleIconsVersion"] as? String)
        #expect(SimpleIcon.simpleIconsVersion == pinned)
    }

    // MARK: - Metadata

    @Test func `An SPDX license and guidelines come through`() {
        let dotnet = SimpleIcon.dotnet()
        #expect(dotnet.title == ".NET")
        #expect(dotnet.license == .spdx("CC0-1.0"))
        #expect(
            dotnet.guidelines
                == .url(
                    "https://github.com/dotnet/brand/blob/c7d0f51b8ec59531332d05fb27a5b758a7a3d689/dotnet-styleGuide-2024.pdf"
                ))
    }

    @Test func `A custom license has the address of its terms`() {
        let custom = SimpleIcon.allCases.filter {
            if case .custom = $0.license { true } else { false }
        }
        #expect(!custom.isEmpty)
        for icon in custom {
            guard case .custom(let url) = icon.license else { continue }
            #expect(url.hasPrefix("https://") || url.hasPrefix("http://"), "\(icon)")
        }
    }

    @Test func `What Simple Icons does not know is unknown`() {
        let swift = SimpleIcon.swift()
        #expect(swift.license == .unknown)
        #expect(swift.aliases == SimpleIcon.Aliases())
    }

    @Test func `Aliases come through`() {
        #expect(SimpleIcon.dotenv().aliases.alsoKnownAs == ["Dotenv"])
    }

    @Test func `A duplicate shares what it leaves out with its brand`() throws {
        // Upstream leaves out a duplicate's hex, source or guidelines when
        // they are the main brand's; the generator fills them in, so every
        // duplicate has all of them.
        for icon in SimpleIcon.allCases {
            for duplicate in icon.aliases.duplicates {
                #expect(!duplicate.title.isEmpty)
                #expect(!duplicate.source.isEmpty)
            }
        }
        let cbc = try #require(
            SimpleIcon.allCases.first { $0.aliases.duplicates.contains { $0.title == "Radio Canada" } })
        let radioCanada = try #require(cbc.aliases.duplicates.first)
        #expect(radioCanada.hex == "FF0000")
    }

    @Test func `Icons are identified by slug`() {
        #expect(SimpleIcon.swift().id == "swift")
        #expect(Set([SimpleIcon.swift(), .swift(), .github()]).count == 2)
        #expect(SimpleIcon.swift().description == "Swift (swift)")
    }
}
