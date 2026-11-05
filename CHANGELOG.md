# Changelog

All notable changes to simple-icons-swift are recorded here. The format
follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) and
the package follows [Semantic Versioning](https://semver.org/), with each
Simple Icons release folded in as `docs/releasing.md` describes. Each
released section becomes the notes of its GitHub release
(`scripts/release/notes.sh`). Changes since the last release wait as
fragments in `changelog.d/` until the release cut writes them here.

## [Unreleased]

## [16.36.2] - 2026-11-05

### Changed

- **Breaking:** every icon is now a static function: write `SimpleIcon.swift()` and `.github()`
  instead of `SimpleIcon.swift` and `.github`. A public static property makes the library export a
  property descriptor per icon, and an app kept the names of all 3,467 in its symbol table even
  when it used six icons. A release build of a program with six icons is now 0.15 MB instead of
  0.5 MB on macOS (0.35 MB instead of 0.6 MB on Linux), measured unstripped with its symbol table.
  To update, add `()` after every icon. `SimpleIcon.allCases` and every icon's properties are
  unchanged (#17).

## [16.36.1] - 2026-11-04

### Changed

- An app now contains only the icons it uses: a release build with six icons is 0.5 MB
  instead of 8.2 MB. Every icon is compiled into the app where it is used, and the others
  never reach the binary. `SimpleIcon.allCases` still lists every icon; an app that uses it
  contains them all (#12).

### Removed

- `SimpleIcon` is no longer `CaseIterable`: the conformance kept every icon in every app.
  `SimpleIcon.allCases` stays and works as before; generic code that needs the protocol can
  add `extension SimpleIcon: @retroactive CaseIterable {}` itself (#12).

### Fixed

- The README and the documentation show `import SimpleIcons` next to `import SimpleIconsSwiftUI`:
  with only the second, a member such as `SimpleIcon.allCases` does not compile.

## [16.36.0] - 2026-11-04

### Changed

- The package's version is now the version of the Simple Icons release it holds: this is
  16.36.0, with the icons of Simple Icons 16.36.0, and the same code as 1.0.0. Depend on
  `from: "16.36.0"`; there is a release for every Simple Icons release from now on.

## [1.0.0] - 2026-11-04

### Added

- Every icon of Simple Icons 16.36.0 as a typed constant on `SimpleIcon` (`SimpleIcon.swift`),
  with its title, slug, brand color, source, guidelines, license and aliases, and `allCases`.
- `svg`, the icon's SVG exactly as Simple Icons publishes it, and `svg(fill:)` in any color.
- `SVGPath`, the icon's path as absolute drawing commands for any graphics API, on every
  platform Swift runs on, Linux included.
- `SimpleIconsSwiftUI`: `SimpleIconView`, `SimpleIconShape`, `Path(_:)` and
  `Color(simpleIcon:)` for iOS, macOS, tvOS, watchOS and visionOS.

[Unreleased]: https://github.com/Vernum-Projecten/simple-icons-swift/compare/v16.36.2...HEAD
[16.36.2]: https://github.com/Vernum-Projecten/simple-icons-swift/compare/v16.36.1...v16.36.2
[16.36.1]: https://github.com/Vernum-Projecten/simple-icons-swift/compare/v16.36.0...v16.36.1
[16.36.0]: https://github.com/Vernum-Projecten/simple-icons-swift/compare/v1.0.0...v16.36.0
[1.0.0]: https://github.com/Vernum-Projecten/simple-icons-swift/releases/tag/v1.0.0
