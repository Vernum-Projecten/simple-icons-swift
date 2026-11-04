---
paths:
  - "**/*.swift"
  - "Package.swift"
  - "Sources/**"
  - "Tests/**"
  - "Tools/**"
---

# Writing Swift here

The one style guide for this package's Swift. It follows Apple's sources:
the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/),
the agent skills that ship with Xcode, and the Swift Evolution proposals
named below. Where this page says less, those decide. Every rule gives its
reason, so a case it does not cover can be argued from that.

## Toolchain and sources of truth

- **`swift-tools-version: 6.2`, Swift 6 language mode**, built and tested
  with Xcode 27.1 (Swift 6.4) and on Linux with Swift 6.2. 6.2 is the floor
  because the generated constants use raw identifiers (SE-0451) for slugs
  such as `1password`; anything newer than 6.2 in the code needs a
  `#if compiler(>=…)` with a 6.2 path, because users on Xcode 26 build the
  same source.
- **Platforms: iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1.** One list,
  in `Package.swift`. An API newer than that gets `@available` or
  `if #available` with a fallback.
- Set `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` when
  `xcode-select` points at the Command Line Tools: their Swift is a
  different version.
- **Apple's guidance ships with Xcode as agent skills.** Run
  `bash scripts/dev/xcode-skills.sh` once per Mac and after every Xcode
  update; it exports them into `.claude/skills/` (git-ignored: they are
  Apple's and come with each Xcode). Read `swiftui-specialist` (with its
  `references/structure.md`, `dataflow.md`, `modifiers.md` and
  `soft-deprecated-apis.md`) before writing or reviewing anything in
  `SimpleIconsSwiftUI`, `swiftui-whats-new-27` before using an SDK 27 API,
  and `modernize-tests` before touching tests.
- **Never guess an API.** Check the SDK's `.swiftinterface` (under
  `xcrun --sdk macosx --show-sdk-path`), Apple's documentation or the
  Swift Evolution proposal first; the skills say the same.

## The public API

This is a library: every `public` name is a promise to every app that
imports it, and breaking one needs a major version (`docs/releasing.md`).
So the public surface is small and every part of it is designed.

- **Clarity at the call site** is the test of a name (API Design
  Guidelines, Fundamentals). Read it as it is used: `SimpleIconView(.swift)`,
  `Color(simpleIcon: .github)`, `icon.svg(fill: "white")`.
- **Names by role, not type; no needless words.** `svg(fill:)`, not
  `svgString(withFillColor:)`. Booleans read as assertions (`isEmpty`).
  Factory methods start with `make`. Abbreviations only when they are the
  term of art (`svg`, `hex`).
- **Argument labels.** A value-preserving conversion has no first label
  (`Path(icon)`); anything else gets one (`Color(simpleIcon:)`, which also
  keeps `Color(.swift)` from being ambiguous with `Color`'s other
  initializers). Defaulted parameters go last and always have a label.
- **Prefer properties and methods to free functions**, and one method with
  default arguments to a family of overloads.
- **Document every public declaration**, starting with a one-line summary
  fragment, in DocC markup (`- Parameter`, `- Returns`, `- Throws`,
  `- Complexity` for anything that is not O(1)). `swift format lint` fails
  otherwise (`AllPublicDeclarationsHaveDocumentation`). Symbol links use
  double backticks so DocC checks them.
- **Access.** `public` only for what an app uses; `package` for what only
  this package's modules share; the rest `internal` or `private`. Tests use
  `@testable import` for internals, never a wider access level. No `open`:
  nothing here is designed for subclassing.
- **Users import both modules.** `SimpleIconsSwiftUI` does not re-export
  `SimpleIcons`: there is no official re-export, and under
  `MemberImportVisibility` (a later Swift's default) a member such as
  `.swift` or `.allCases` needs its defining module imported anyway, so a
  type alias would only postpone the error. Every example in the README and
  DocC shows `import SimpleIcons` next to `import SimpleIconsSwiftUI`.
- **A plain `import` is internal** (`InternalImportsByDefault`). Write
  `public import X` only when a `public` declaration's signature uses a type
  from X (`SimpleIconsSwiftUI` re-exposes `SwiftUI` and `SimpleIcons`), so
  the module interface shows exactly what it exposes. Never `@_exported` or
  `@_implementationOnly`.
- **Typed, never optional.** Every icon is a constant (`SimpleIcon.swift`),
  so the compiler checks the name and nothing can fail at run time. There
  is no string lookup such as `init?(slug:)`: adding one later breaks
  nothing, removing one can only happen in a Simple Icons major (our
  version is theirs, `docs/releasing.md`), so it comes only when someone
  needs it and the owner agrees. Metadata that can be absent is modeled, not left
  optional: an enum with an `.unknown` case (`License`, `Guidelines`), an
  empty list (`Aliases`), or the main brand's value (`Duplicate`).
- **Value types.** Public types are `struct`s and `enum`s, `Sendable` and
  `Hashable` where it makes sense, so they cross actors and go into sets and
  `ForEach` without ceremony.
- **Typed throws** (SE-0413) for an error the caller can act on
  (`SVGPath.ParseError` carries the offset and the elements before it).
- **The core module needs only Foundation**, and only where the standard
  library has no answer (the arc math). No UIKit, AppKit, CoreGraphics or
  SwiftUI in `SimpleIcons`, so it builds on Linux and for server-side Swift.
  Anything platform-specific goes in a module of its own.

## Concurrency

Every target builds in Swift 6 language mode with the upcoming features
`ExistentialAny`, `MemberImportVisibility`, `InternalImportsByDefault`,
`NonisolatedNonsendingByDefault` and `InferIsolatedConformances` (what
Xcode's "Approachable Concurrency" turns on, plus the import rules). CI
builds with warnings as errors.

- No `@preconcurrency`, `nonisolated(unsafe)` or `@unchecked Sendable` to
  silence the compiler, in tests either; they hide the races strict
  concurrency exists to find.
- The library holds no mutable state. The icon index is a `static let`,
  which Swift initializes once, lazily and thread-safely.
- No `DispatchQueue`, completion handlers or Combine.

## Types and syntax

- `any P` for an existential, `some P` for an opaque type
  (`ExistentialAny` requires it).
- A raw identifier (SE-0451) is a slug that is not a plain Swift name:
  ``SimpleIcon.`1password` ``. The generator decides when; never by hand.
- No force unwrap or `try!` in `Sources/`: a library must not crash an app.
  Where a value cannot be missing, say why in a comment and use `guard`
  with a sensible fallback (an unparseable path draws what parsed, as SVG
  does).
- A warning we accept on purpose gets `@diagnose` (SE-0522, Swift 6.4,
  so inside `#if compiler(>=6.4)`) on the smallest declaration, with a
  comment why. Never to hide a warning we could fix.

## SwiftUI (`SimpleIconsSwiftUI`)

From Apple's `swiftui-specialist`; read it for the examples.

- **A view takes only the data it reads.** `SimpleIconShape` stores the
  path string, not the whole `SimpleIcon`: SwiftUI compares a view's
  stored properties to decide whether to draw again, and the metadata it
  never reads would only make that slower.
- **Keep `init` cheap.** It runs on every parent redraw. Parse the path in
  `path(in:)`, never in `init`.
- **Follow the system.** A shape fills with the foreground style, like an
  SF Symbol, so `foregroundStyle`, `tint` and dark mode work as people
  expect. The brand color is opt-in (`Color(simpleIcon:)`).
- **Accessibility is not optional.** A view that shows an icon has the
  brand's name as its label and the image trait. Use
  `accessibilityLabel(_:)`, never the soft-deprecated `accessibility(label:)`.
- **No soft-deprecated API** (`soft-deprecated-apis.md` lists them):
  `foregroundStyle`, not `foregroundColor`; `.overlay { }`, not
  `.overlay(view)`.
- **Modifiers.** Vary a modifier's argument with a ternary, never an
  `if`/`else` that swaps the view's identity.
- **Brand names are not localized.** "GitHub" is "GitHub" in every
  language, so labels use `Text(verbatim:)`. Text of our own that a person
  reads (none yet) goes in a String Catalog in the module, looked up with
  `bundle: #bundle`, as `localization.md` says for packages.
- Everything in the module is inside `#if canImport(SwiftUI)`, so the
  package still builds on Linux.

## Generated code

`Sources/SimpleIcons/Generated/` and `simple-icons.json` come from
`scripts/dev/update-icons.sh`, never from a hand edit (the
`protect_generated.sh` hook refuses one). To change what is generated,
change `Tools/IconGenerator` and run the script. The generator refuses to
write when an upstream SVG is not exactly what `SimpleIcon.svg` rebuilds,
so the two must change together.

## Tests

From Apple's `modernize-tests`.

- **Swift Testing** (`@Suite`, `@Test`, `#expect`, `#require`). XCTest
  only for what Swift Testing cannot do: UI tests (none here) and
  `measure { }` performance tests.
- A suite is a `struct`; its `init` builds the fixtures, and Swift Testing
  makes a fresh instance per test, so tests cannot leak state into each
  other.
- **One input per case**: a loop over inputs becomes `@Test(arguments:)`,
  so a failure names the input and the others still run. Every icon is a
  case of its own (`SimpleIcon.allCases`).
- `try #require` for what the rest of the test needs, instead of `guard`
  plus `Issue.record` and `return`. Never turn a `#require` into an
  `#expect`: the test would go on with a bad value.
- `#require(throws: SomeError.self)` to get the error and check it.
- Test names that read as a sentence use a raw identifier:
  ``@Test func `Finds an icon by its slug`()``.
- A test that needs SwiftUI sits in `SimpleIconsSwiftUITests` inside
  `#if canImport(SwiftUI)`; everything else runs on Linux too.
- Hunt a flaky test by repeating it:
  `swift test --filter <Test> --maximum-repetitions 100 --repeat-until fail`.
- Never weaken, skip or delete a test to make a build pass.

## Formatting

`swift format` (part of the toolchain) with `.swift-format`: 4 spaces,
120 columns, `#if` blocks not indented, every public declaration
documented. `bash scripts/dev/format.sh` rewrites;
`bash scripts/dev/format.sh --check` is the gate. The generated files are
left out.
