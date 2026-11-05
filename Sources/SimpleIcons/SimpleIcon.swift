/// A brand icon from Simple Icons, with its metadata and SVG path.
///
/// Every icon in the collection is a static function named after its slug,
/// checked by the compiler and completed by Xcode. Each one is compiled
/// into your app only when you use it, so an app with a few icons stays
/// small:
///
/// ```swift
/// let icon = SimpleIcon.swift()
/// print(icon.title)  // "Swift"
/// print(icon.hex)    // "F05138"
/// ```
///
/// A slug that starts with a digit or is a Swift keyword is written with
/// backticks, as Swift's raw identifiers are:
///
/// ```swift
/// let password = SimpleIcon.`1password`()
/// let await = SimpleIcon.`await`()
/// ```
///
/// ``allCases`` lists every icon, to show them all or to search them; an app
/// that uses it contains every icon.
///
/// - Important: Simple Icons is CC0, but the brands are not yours. Read the
///   [Simple Icons disclaimer](https://github.com/simple-icons/simple-icons/blob/develop/DISCLAIMER.md),
///   the icon's `license` and its brand `guidelines` before you use it.
public struct SimpleIcon: Sendable {
    /// The brand name, such as "Swift" or ".NET".
    public let title: String

    /// The unique identifier, such as `swift` or `dotnet`, which is also the
    /// name of the icon's function.
    public let slug: String

    /// The brand color as six uppercase hexadecimal digits, without `#`.
    public let hex: String

    /// The address the icon was taken from.
    public let source: String

    /// The brand's guidelines for using its logo.
    public let guidelines: Guidelines

    /// The license the icon is available under.
    public let license: License

    /// Other names of the brand; empty when it has none.
    public let aliases: Aliases

    /// The SVG path data of the icon, in a 24 by 24 coordinate space.
    public let path: String

    /// Creates an icon from its metadata.
    ///
    /// The generated icon functions call this; you only need it for an icon that
    /// is not in Simple Icons.
    public init(
        title: String,
        slug: String,
        hex: String,
        source: String,
        guidelines: Guidelines = .unknown,
        license: License = .unknown,
        aliases: Aliases = Aliases(),
        path: String
    ) {
        self.title = title
        self.slug = slug
        self.hex = hex
        self.source = source
        self.guidelines = guidelines
        self.license = license
        self.aliases = aliases
        self.path = path
    }
}

// MARK: - Guidelines and license

extension SimpleIcon {
    /// Where a brand publishes the rules for using its logo.
    ///
    /// Simple Icons is still collecting these: ``unknown`` does not mean the
    /// brand has no guidelines. Check the icon's ``SimpleIcon/source`` then.
    public enum Guidelines: Sendable, Hashable {
        /// The address of the brand's guidelines.
        case url(String)
        /// Simple Icons has no address for the brand's guidelines.
        case unknown
    }

    /// The license an icon is available under.
    ///
    /// Simple Icons is still collecting licenses: ``unknown`` does not mean
    /// the icon has no license.
    public enum License: Sendable, Hashable {
        /// A license with an [SPDX identifier](https://spdx.org/licenses/),
        /// such as `CC0-1.0` or `MIT`.
        case spdx(String)
        /// A license of the brand's own, with the address of its terms.
        case custom(url: String)
        /// Simple Icons does not know the license.
        case unknown
    }
}

// MARK: - Aliases

extension SimpleIcon {
    /// Other names a brand goes by. Every list is empty when there are none.
    public struct Aliases: Sendable, Hashable {
        /// Names the brand is also known as, such as "Dotenv" for ".ENV".
        public let alsoKnownAs: [String]

        /// Brands that use the same icon under another name or color.
        public let duplicates: [Duplicate]

        /// The brand's title in other languages, keyed by BCP 47 language
        /// tag such as `zh-CN`.
        public let localizedTitles: [String: String]

        /// Titles the brand used before.
        public let formerTitles: [String]

        /// Creates the aliases of a brand.
        public init(
            alsoKnownAs: [String] = [],
            duplicates: [Duplicate] = [],
            localizedTitles: [String: String] = [:],
            formerTitles: [String] = []
        ) {
            self.alsoKnownAs = alsoKnownAs
            self.duplicates = duplicates
            self.localizedTitles = localizedTitles
            self.formerTitles = formerTitles
        }
    }

    /// A brand that uses the same icon as another one, under its own name.
    ///
    /// What Simple Icons does not give for the duplicate it takes from the
    /// main brand, and so do these properties.
    public struct Duplicate: Sendable, Hashable {
        /// The brand's name.
        public let title: String

        /// The brand's color, as six uppercase hexadecimal digits.
        public let hex: String

        /// The address the brand's color was taken from.
        public let source: String

        /// The brand's guidelines for using its logo.
        public let guidelines: Guidelines

        /// Creates a duplicate.
        public init(title: String, hex: String, source: String, guidelines: Guidelines = .unknown) {
            self.title = title
            self.hex = hex
            self.source = source
            self.guidelines = guidelines
        }
    }
}

// MARK: - Identity

// Not `CaseIterable`: a conformance is kept in every app, and its
// `allCases` would keep every icon with it, 6 MB more in an app that shows
// a handful (#12). `allCases` is a plain static property instead.
extension SimpleIcon: Identifiable, Hashable {
    /// The slug, which is unique within Simple Icons.
    public var id: String { slug }

    /// Two icons are equal when they have the same slug.
    public static func == (lhs: SimpleIcon, rhs: SimpleIcon) -> Bool {
        lhs.slug == rhs.slug
    }

    /// Hashes the slug, the part that makes two icons equal.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(slug)
    }
}

extension SimpleIcon: CustomStringConvertible {
    /// The title and the slug, such as `Swift (swift)`.
    public var description: String { "\(title) (\(slug))" }
}
