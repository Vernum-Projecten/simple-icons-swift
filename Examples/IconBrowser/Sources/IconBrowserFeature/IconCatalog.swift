internal import Foundation
public import Observation
public import SimpleIcons

/// The icons the browser shows, filtered by the search text.
///
/// The filtered list is stored and recomputed only when the search text
/// changes, as Apple's SwiftUI guidance asks, so the grid never filters
/// thousands of icons while it draws.
@MainActor
@Observable
public final class IconCatalog {
    /// The search text; matches the title, the slug and other names.
    public var query: String = "" {
        didSet {
            guard query != oldValue else { return }
            visibleIcons = Self.icons(matching: query)
        }
    }

    /// The icons that match ``query``, in Simple Icons' order (by title).
    public private(set) var visibleIcons: [SimpleIcon] = SimpleIcon.allCases

    /// Creates a catalog that shows every icon.
    public init() {}

    /// The icons whose title, slug or other names contain the text,
    /// ignoring case and diacritics. Every icon for empty text.
    static func icons(matching text: String) -> [SimpleIcon] {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return SimpleIcon.allCases }
        return SimpleIcon.allCases.filter { icon in
            icon.title.localizedStandardContains(text)
                || icon.slug.localizedStandardContains(text)
                || icon.aliases.alsoKnownAs.contains { $0.localizedStandardContains(text) }
                || icon.aliases.formerTitles.contains { $0.localizedStandardContains(text) }
        }
    }
}
