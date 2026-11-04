# Changelog

All notable changes to simple-icons-swift are recorded here. The format
follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) and
the package follows [Semantic Versioning](https://semver.org/), with each
Simple Icons release folded in as `docs/releasing.md` describes. Each
released section becomes the notes of its GitHub release
(`scripts/release/notes.sh`). Changes since the last release wait as
fragments in `changelog.d/` until the release cut writes them here.

## [Unreleased]

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

[Unreleased]: https://github.com/Vernum-Projecten/simple-icons-swift/compare/v16.36.0...HEAD
[16.36.0]: https://github.com/Vernum-Projecten/simple-icons-swift/compare/v1.0.0...v16.36.0
[1.0.0]: https://github.com/Vernum-Projecten/simple-icons-swift/releases/tag/v1.0.0
