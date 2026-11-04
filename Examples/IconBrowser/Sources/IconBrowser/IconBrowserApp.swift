import IconBrowserFeature
import SwiftUI

/// The example app on macOS: one window with the icon browser.
@main
struct IconBrowserApp: App {
    var body: some Scene {
        WindowGroup("Simple Icons") {
            IconBrowserView()
                .frame(minWidth: 520, minHeight: 420)
        }
    }
}
