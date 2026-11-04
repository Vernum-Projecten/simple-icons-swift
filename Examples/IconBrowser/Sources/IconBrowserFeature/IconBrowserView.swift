import SimpleIcons
import SimpleIconsSwiftUI
public import SwiftUI

/// Every icon in a searchable grid; selecting one shows its details.
public struct IconBrowserView: View {
    @State private var catalog = IconCatalog()

    /// Creates the browser.
    public init() {}

    /// The grid, the search field and the navigation to an icon's details.
    public var body: some View {
        NavigationStack {
            IconGrid(icons: catalog.visibleIcons, query: catalog.query)
                .navigationTitle("Simple Icons")
                .searchable(text: $catalog.query, prompt: "Title, slug or other name")
                .navigationDestination(for: SimpleIcon.self) { icon in
                    IconDetailView(icon: icon)
                }
        }
    }
}

/// The icons as tiles, or a message when the search finds none.
struct IconGrid: View {
    let icons: [SimpleIcon]
    let query: String

    var body: some View {
        if icons.isEmpty {
            ContentUnavailableView.search(text: query)
        } else {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 12)], spacing: 12) {
                    ForEach(icons) { icon in
                        NavigationLink(value: icon) {
                            IconTile(icon: icon)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }
}

/// One icon in the grid: the icon in its brand color and its title.
struct IconTile: View {
    let icon: SimpleIcon

    var body: some View {
        VStack(spacing: 8) {
            SimpleIconView(icon)
                .foregroundStyle(Color(simpleIcon: icon))
                .frame(width: 36, height: 36)
            Text(icon.title)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 88)
        .padding(8)
        .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }
}
