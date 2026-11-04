import SimpleIcons
import Testing

@testable import IconBrowserFeature

@MainActor
@Suite struct IconCatalogTests {
    @Test func `Shows every icon before a search`() {
        #expect(IconCatalog().visibleIcons.count == SimpleIcon.allCases.count)
    }

    @Test(arguments: [
        ("swift", SimpleIcon.swift),
        ("SWIFT", SimpleIcon.swift),
        ("nodedotjs", SimpleIcon.nodedotjs),
        ("Node.js", SimpleIcon.nodedotjs),
        ("Dotenv", SimpleIcon.dotenv),
    ])
    func `Finds an icon by title, slug or other name`(query: String, icon: SimpleIcon) {
        let catalog = IconCatalog()
        catalog.query = query
        #expect(catalog.visibleIcons.contains(icon))
    }

    @Test func `Finds nothing for text no icon has`() {
        let catalog = IconCatalog()
        catalog.query = "no icon is called this"
        #expect(catalog.visibleIcons.isEmpty)
    }

    @Test func `Clearing the search shows every icon again`() {
        let catalog = IconCatalog()
        catalog.query = "git"
        catalog.query = "  "
        #expect(catalog.visibleIcons.count == SimpleIcon.allCases.count)
    }
}
