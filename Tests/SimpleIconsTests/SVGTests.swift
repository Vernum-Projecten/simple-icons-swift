import SimpleIcons
import Testing

@Suite struct SVGTests {
    @Test func `The SVG is the file Simple Icons publishes`() {
        let svg = SimpleIcon.swift.svg
        #expect(
            svg.hasPrefix(
                #"<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>Swift</title><path d="M7.508 0c"#
            ))
        #expect(svg.hasSuffix(#"-1.893-7.992z"/></svg>"#))
    }

    // As in the upstream files: & < > as entities, other text outside ASCII
    // as decimal references, quotes untouched.
    @Test(arguments: [
        (SimpleIcon.`1and1`, "<title>1&amp;1</title>"),
        (SimpleIcon.byjus, "<title>Byju's</title>"),
        (SimpleIcon.aldisud, "<title>Aldi S&#252;d</title>"),
    ])
    func `Titles are escaped as upstream escapes them`(icon: SimpleIcon, title: String) {
        #expect(icon.svg.contains(title))
    }

    @Test func `A fill goes on the root element`() {
        let svg = SimpleIcon.swift.svg(fill: "#F05138")
        #expect(
            svg.hasPrefix(
                ##"<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" fill="#F05138"><title>"##))
    }

    @Test func `A fill cannot break out of its attribute`() {
        let svg = SimpleIcon.swift.svg(fill: #"red" onload="alert(1)"#)
        #expect(svg.contains(#"fill="red&quot; onload=&quot;alert(1)""#))
        #expect(!svg.contains(#"" onload=""#))
    }
}
