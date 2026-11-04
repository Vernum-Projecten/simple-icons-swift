#if canImport(SwiftUI)
import SimpleIcons
import SwiftUI
import Testing

@testable import SimpleIconsSwiftUI

@Suite struct SimpleIconsSwiftUITests {
    @Test func `The brand color comes from the hex`() {
        let (red, green, blue) = Color.components(ofHex: "F05138")
        #expect(abs(red - 240.0 / 255) < 1e-9)
        #expect(abs(green - 81.0 / 255) < 1e-9)
        #expect(abs(blue - 56.0 / 255) < 1e-9)
    }

    @Test(arguments: ["", "F0513", "GGGGGG", "F051388"])
    func `Something that is not a color is black`(hex: String) {
        let (red, green, blue) = Color.components(ofHex: hex)
        #expect(red == 0 && green == 0 && blue == 0)
    }

    @Test(arguments: [
        CGRect(x: 0, y: 0, width: 48, height: 48),
        CGRect(x: 10, y: 20, width: 100, height: 40),
        CGRect(x: 0, y: 0, width: 30, height: 90),
    ])
    func `The shape is square and centered in its frame`(rect: CGRect) {
        let side = min(rect.width, rect.height)
        let square = CGRect(x: rect.midX - side / 2, y: rect.midY - side / 2, width: side, height: side)
        // A square brand mark fills its square; check one that does.
        let bounds = SimpleIconShape(.swift).path(in: rect).boundingRect
        #expect(abs(bounds.minX - square.minX) < 0.01)
        #expect(abs(bounds.minY - square.minY) < 0.01)
        #expect(abs(bounds.maxX - square.maxX) < 0.01)
        #expect(abs(bounds.maxY - square.maxY) < 0.01)
    }

    @Test func `The path is in 24 by 24 units`() {
        let bounds = Path(SimpleIcon.swift).boundingRect
        #expect(bounds.minX >= -0.01 && bounds.maxX <= 24.01)
        #expect(bounds.minY >= -0.01 && bounds.maxY <= 24.01)
        #expect(bounds.width > 23)
    }

    @Test func `The shape proposes a square`() {
        let size = SimpleIconShape(.swift).sizeThatFits(ProposedViewSize(width: 50, height: 30))
        #expect(size == CGSize(width: 30, height: 30))
    }
}
#endif
