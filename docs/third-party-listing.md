# The Simple Icons third-party listing

The Simple Icons README has a table of
[third-party libraries](https://github.com/simple-icons/simple-icons#third-party-libraries):
"We only keep items in the list that are at least up to date with our
previous major version. Maintain a library? Submit a PR to include it in the
list above." There is no Swift entry yet. This page holds the entry and what
has to be true before the owner opens the pull request (Claude sessions do
not open it; the hook refuses).

## Before asking

- [ ] A release is published (`docs/releasing.md`) and resolves with
  `.package(url: "https://github.com/Vernum-Projecten/simple-icons-swift", from: "1.0.0")`.
- [ ] The repository is public, CI is green on `main`, and the README shows
  install, usage and the legal disclaimer.
- [ ] The package is on the [Swift Package Index](https://swiftpackageindex.com)
  with its documentation (`.spi.yml`), so the link from the table has
  docs and the platform and Swift compatibility (issue #1 has the steps).
- [ ] `icons.yml` has filed an icon update, and it has been done, merged and
  released, showing that the package keeps up.
- [ ] `simple-icons.json` on `main` has the current Simple Icons version:
  the table's version column reads it.

## The entry

The table is sorted by the library's platform; Swift goes between Svelte
and Vue. One row, in the format of the others (the icon from
`cdn.simpleicons.org`, the author, a license badge, and a version badge
that reads `simpleIconsVersion` from `simple-icons.json` on `main`):

```markdown
| <a href="https://github.com/Vernum-Projecten/simple-icons-swift"><img src="https://cdn.simpleicons.org/swift/000/fff" alt="Swift" align=left width=24>Swift package</a> | [@Vernum-Projecten](https://github.com/Vernum-Projecten) | ![License](https://img.shields.io/github/license/Vernum-Projecten/simple-icons-swift?label=) | ![Simple Icons version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FVernum-Projecten%2Fsimple-icons-swift%2Fmain%2Fsimple-icons.json&query=%24.simpleIconsVersion&label=) |
```

Check both badges render before opening the pull request: open the two
`img.shields.io` addresses in a browser.

## The pull request

Fork `simple-icons/simple-icons`, branch from `develop` (their default
branch), add the row to `README.md`, and open the pull request against
`develop`. Read their
[CONTRIBUTING.md](https://github.com/simple-icons/simple-icons/blob/develop/CONTRIBUTING.md)
first; follow their pull request template. A title in their style:

```text
Add Swift package to third-party libraries
```

A body:

```markdown
Adds simple-icons-swift, a Swift package with every Simple Icons icon as a
typed constant, the SVG byte for byte, a parsed path for any graphics API
(Linux included), and a SwiftUI view and shape for iOS, macOS, tvOS,
watchOS and visionOS.

It follows every Simple Icons release: a daily workflow files each new
release as an issue, and the icons are regenerated from the npm package
(checked against its sha512). The version badge reads simple-icons.json on
main.

- Repository: https://github.com/Vernum-Projecten/simple-icons-swift
- Documentation: https://swiftpackageindex.com/Vernum-Projecten/simple-icons-swift/documentation
```

## Afterwards

The entry stays only while the package keeps up with at least the
previous Simple Icons major. Merge and release the icon pull requests,
above all the one of a new major.
