internal import Foundation
public import SimpleIcons
import SimpleIconsSwiftUI
public import SwiftUI

/// Everything Simple Icons knows about one icon, and its SVG to share.
public struct IconDetailView: View {
    let icon: SimpleIcon

    /// Creates the details of an icon.
    public init(icon: SimpleIcon) {
        self.icon = icon
    }

    /// The icon large, then its metadata and its SVG.
    public var body: some View {
        Form {
            Section {
                IconHero(icon: icon)
            }
            Section("Details") {
                LabeledContent("Slug") {
                    Text(verbatim: "SimpleIcon.\(icon.slug)").monospaced().textSelection(.enabled)
                }
                LabeledContent("Brand color") {
                    HStack {
                        Circle().fill(Color(simpleIcon: icon)).frame(width: 14, height: 14)
                        Text(verbatim: "#\(icon.hex)").monospaced().textSelection(.enabled)
                    }
                }
                LabeledContent("License") { LicenseText(license: icon.license) }
                GuidelinesRow(guidelines: icon.guidelines)
                if let source = URL(string: icon.source) {
                    Link("Source", destination: source)
                }
            }
            AliasesSection(aliases: icon.aliases)
            Section("SVG") {
                Text(verbatim: icon.svg)
                    .font(.caption.monospaced())
                    .textSelection(.enabled)
                    .lineLimit(6)
                ShareLink("Share SVG", item: icon.svg)
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Text(verbatim: icon.title))
    }
}

/// The icon large, in its brand color.
struct IconHero: View {
    let icon: SimpleIcon

    var body: some View {
        SimpleIconView(icon)
            .foregroundStyle(Color(simpleIcon: icon))
            .frame(width: 120, height: 120)
            .frame(maxWidth: .infinity)
            .padding(.vertical)
    }
}

/// The license, as Simple Icons records it.
struct LicenseText: View {
    let license: SimpleIcon.License

    var body: some View {
        switch license {
        case .spdx(let identifier):
            Text(verbatim: identifier)
        case .custom(let url):
            if let url = URL(string: url) {
                Link("Custom", destination: url)
            } else {
                Text("Custom")
            }
        case .unknown:
            Text("Unknown").foregroundStyle(.secondary)
        }
    }
}

/// A link to the brand's guidelines, or a note that Simple Icons has none.
struct GuidelinesRow: View {
    let guidelines: SimpleIcon.Guidelines

    var body: some View {
        switch guidelines {
        case .url(let address):
            if let url = URL(string: address) {
                Link("Brand guidelines", destination: url)
            } else {
                LabeledContent("Brand guidelines", value: address)
            }
        case .unknown:
            LabeledContent("Brand guidelines") {
                Text("Not recorded; check the source").foregroundStyle(.secondary)
            }
        }
    }
}

/// Other names of the brand, when it has any.
struct AliasesSection: View {
    let aliases: SimpleIcon.Aliases

    var body: some View {
        if aliases != SimpleIcon.Aliases() {
            Section("Also known as") {
                ForEach(aliases.alsoKnownAs + aliases.formerTitles, id: \.self) { name in
                    Text(verbatim: name)
                }
                ForEach(aliases.localizedTitles.sorted { $0.key < $1.key }, id: \.key) { language, title in
                    LabeledContent {
                        Text(verbatim: title)
                    } label: {
                        Text(verbatim: language)
                    }
                }
                ForEach(aliases.duplicates, id: \.title) { duplicate in
                    Text(verbatim: duplicate.title)
                }
            }
        }
    }
}
