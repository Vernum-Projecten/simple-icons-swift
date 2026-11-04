# CLAUDE.md

simple-icons-swift is a Swift package that gives Swift and SwiftUI code
every brand icon of [Simple Icons](https://simpleicons.org): typed
constants with each icon's metadata, the SVG, the parsed path and a SwiftUI
shape and view. Maintained by Vernum Projecten B.V. in
`Vernum-Projecten/simple-icons-swift`; MIT (the icons are CC0 through
Simple Icons, the brands belong to their owners). `README.md` is the
overview for users; Swift is written as `.claude/rules/swift.md` says.

The goal is a place in the
[third-party libraries](https://github.com/simple-icons/simple-icons#third-party-libraries)
of the Simple Icons README, which keeps only libraries that are at least up
to date with its previous major version. So the package tracks every
simple-icons release (Icons, below) and `docs/third-party-listing.md` holds
the entry and what has to be true before it is requested.

## Repository map

- `Package.swift`: the package (tools 6.2, Swift 6 language mode, iOS 16,
  macOS 13, tvOS 16, watchOS 9, visionOS 1). Two library products:
  - `SimpleIcons` (`Sources/SimpleIcons/`), Foundation only, builds on
    Linux: `SimpleIcon` (the struct: `title`, `slug`, `hex`, `source`,
    `guidelines` and `license` as enums with an `.unknown` case, `aliases`
    with empty lists when there are none, `path`; `Identifiable`,
    `Hashable` by slug, `CaseIterable`; one typed constant per icon and no
    optional anywhere in the API), `SimpleIcon+SVG` (`svg`, byte for byte the upstream
    file, and `svg(fill:)`), `Path/` (`SVGPath`, the parsed path as five
    absolute elements; `SVGPathParser`, the SVG 2 path grammar with SVG's
    error handling; `SVGArc`, arcs to cubic curves per SVG 2 appendix B),
    `SimpleIcons.docc/` (the DocC catalog) and `Generated/` (Icons, below).
  - `SimpleIconsSwiftUI` (`Sources/SimpleIconsSwiftUI/`), all inside
    `#if canImport(SwiftUI)`: `SimpleIconShape` (a `Shape`, square and
    centered), `SimpleIconView` (the shape with an accessibility label,
    like `Image(systemName:)`), `Path(_:)` for an icon or an `SVGPath`, and
    `Color(simpleIcon:)`.
- `Tests/`: Swift Testing. `SimpleIconsTests` (lookup, metadata, SVG
  escaping, the parser command by command, and every icon parsed and inside
  its box) and `SimpleIconsSwiftUITests` (color, shape geometry).
- `Tools/IconGenerator/`: a package of its own (so users never fetch it)
  with the `generate-icons` executable that writes `Generated/`.
- `simple-icons.json`: the pinned simple-icons version and the npm
  tarball's sha512. The README badge and the version column of the Simple
  Icons listing read `simpleIconsVersion` from it.
- `scripts/dev/`: `update-icons.sh` (Icons, below), `format.sh`
  (`swift format`, `--check` for the gate), `xcode-skills.sh` (exports
  Apple's agent skills into `.claude/skills/`, git-ignored).
- `scripts/checks/changelog-guard.sh`: the changelog fragment guard CI runs
  on every pull request (`--self-test` proves it).
- `scripts/release/`: `changelog.sh` (`--check`, `--preview`,
  `--assemble` of the fragments), `check-version.sh vX.Y.Z` (tag, changelog
  section and no fragment left agree), `notes.sh vX.Y.Z` (the changelog
  section, the release's notes), `protect-tags.sh` (the `v*` tag ruleset).
- `scripts/gh/`: tracker helpers (from Pullwatch, which took them from
  FerroLICENCE): `fields.sh` (issue type, Priority, Effort), `rel.sh`
  (sub-issues and blocked-by), `labels.sh` (the label set).
- `changelog.d/`: the fragments of the next release and their format
  (`README.md`); `CHANGELOG.md` (Keep a Changelog) holds the released
  sections.
- `.github/workflows/`: `ci.yml` (every pull request and push to `main`:
  shellcheck, actionlint, the scripts' self-tests, `swift format`, `swift
  test` on macOS with warnings as errors, a build for iOS, tvOS, watchOS and
  visionOS, `swift test` on Linux, the DocC build, and the generated code
  against the pin), `changelog.yml` (the fragment guard, also when a label
  changes), `icons.yml` (daily: a new simple-icons release becomes an
  issue; it only writes issues, never code) and `release.yml` (a `v*` tag: checks and tests, then a draft
  GitHub release with the changelog section as notes, for the owner to
  publish).
- `docs/`: `releasing.md` (versioning and the release procedure),
  `third-party-listing.md` (the Simple Icons README entry), `updating-icons.md`
  (how the icon updates work and what to do when the generator refuses).
- `.githooks/`: `pre-commit` (refuses private keys, tokens, certificates)
  and `commit-msg` (strips AI attribution). Install once per clone:
  `git config core.hooksPath .githooks`.
- `.spi.yml`: Swift Package Index builds the DocC documentation of both
  products.

## Icons

Simple Icons releases weekly (usually Sunday) and a major about every six
months, which removes icons (`VERSIONING.md` upstream).

- `bash scripts/dev/update-icons.sh --latest` (or `X.Y.Z`) downloads the
  npm package, checks its sha512 against the registry, regenerates
  `Generated/` and writes `simple-icons.json`. Without an argument it
  regenerates the pinned version, which must change nothing: CI checks
  that. `--check` says whether a newer release exists. Moving to another
  release also writes its changelog fragments (issue 0).
- `icons.yml` checks npm every day and opens an issue "Update the icons to
  Simple Icons X.Y.Z" (labels `icons`, and `breaking` when icons go) with
  the new and removed slugs, or moves the open one to the newest version.
  It has `issues: write` only and no token of ours, on purpose. Doing such
  an issue: branch `chore/simple-icons-X.Y.Z`, run
  `update-icons.sh X.Y.Z`, the gates, and a pull request that closes it.
- Never edit `Generated/` or `simple-icons.json` by hand; the
  `protect_generated.sh` hook refuses it. Change `Tools/IconGenerator` and
  rerun. When the generator refuses (an SVG it cannot rebuild, a slug that
  is no Swift name), `docs/updating-icons.md` says what to change.
- A simple-icons major removes constants, which breaks code that used
  them: it is a major release here too (`docs/releasing.md`).

## Hard rules

- **No secrets in the tree.** The pre-commit hook and the Claude
  `protect_secrets.sh` hook refuse private keys, tokens and certificates.
- **`svg` is the upstream file, byte for byte.** The generator checks every
  icon; never weaken that check.
- **The public API is a promise.** Removing or renaming a public symbol,
  or changing its meaning, is a major version. Prefer adding.
- **Typed constants, no optionals in the public API.** No string lookup
  and no `?` on icon metadata (`.claude/rules/swift.md`, The public API).
- **No crash in `Sources/`**: no force unwrap, `try!` or `fatalError` a
  user's input can reach.
- **The core module stays Foundation-only** and builds on Linux.
- **Never weaken, skip or delete a test** to make a build pass.
- **No AI attribution in commits, PRs or issues.** No `Co-authored-by`, no
  "Generated with", no robot emoji. The `commit-msg` hook strips it and the
  Claude Bash hook refuses the command.
- **The owner opens anything in `simple-icons/simple-icons`**, pushes
  release tags and publishes releases (immutable once published); the
  Claude Bash hook refuses all three.
- **Prose has no AI tells**, in docs, DocC, commits and PRs: no em dashes,
  no middle dot "·" as a separator, no "not X but Y", no buzzwords.
- **Our own branding only.** The README and docs use our logo
  (`docs/images/logo-light.svg`, `logo-dark.svg`), never the Simple Icons
  logo or another brand's icon as decoration: we are not Simple Icons and
  not affiliated with the brands.
- **README examples compile.** Every code example in `README.md` is also in
  `Tests/SimpleIconsSwiftUITests/ReadmeExamples.swift`; change both together.
- **Respect the brands.** Docs and examples point to the Simple Icons
  [disclaimer](https://github.com/simple-icons/simple-icons/blob/develop/DISCLAIMER.md);
  never suggest an icon may be used without checking its license and
  guidelines.

## Gates (run before every commit)

The same as CI (`.github/workflows/ci.yml`), warnings as errors:

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift build -Xswiftc -warnings-as-errors
swift test -Xswiftc -warnings-as-errors
bash scripts/dev/format.sh --check
shellcheck --severity=style scripts/*/*.sh .claude/hooks/*.sh .githooks/*
actionlint
bash scripts/release/changelog.sh --check
```

After a change to `Tools/IconGenerator` or `SimpleIcon+SVG.swift`, also
`bash scripts/dev/update-icons.sh && git diff --exit-code -- Sources simple-icons.json`.
After a change to `SimpleIconsSwiftUI`, build for the other platforms:
`xcodebuild build -scheme simple-icons-swift-Package -destination 'generic/platform=iOS'`
(and `tvOS`, `watchOS`, `visionOS`).

## Workflow

The tracker is GitHub Issues in `Vernum-Projecten/simple-icons-swift`. The
type (Bug, Feature, Task), the priority (Urgent, High, Medium, Low) and the
effort (High, Medium, Low) are GitHub's native issue type and the
Vernum-Projecten organisation's `Priority` and `Effort` issue fields, never
labels. File an issue with `scripts/gh/fields.sh new <type> <priority>
<effort> <gh issue create args>`, never a bare `gh issue create`. A Task
carries exactly one work-kind label (`documentation`, `chore`, `refactor`,
`perf`, `test`, `ci`); a Bug and a Feature carry none. Epics are parents
(`scripts/gh/rel.sh parent <child> <epic>`); order is `rel.sh blocked-by`.
`gh repo set-default Vernum-Projecten/simple-icons-swift` once per clone.

A change lands in `main` through a pull request, on a conventional-type
branch (`fix/`, `feat/`, or the Task's work kind), with conventional commit
subjects in English (`feat: …`, `fix: …`). The PR body says what changed
and why and links the issue. A request for a new icon or a change to one
goes to [Simple Icons](https://github.com/simple-icons/simple-icons/issues),
never here: the icons come from there unchanged.

Every change a user of the package notices adds a fragment under
`changelog.d/` (`changelog.d/README.md`), never a line under
`[Unreleased]` in `CHANGELOG.md`; the `Changelog` workflow fails a pull
request that changes `Sources/` or `Package.swift` without one, unless it
has the `no-changelog` label.

## Releases

Semantic Versioning of our own, starting at 1.0.0, with the Simple Icons
release folded in: a simple-icons major (icons removed) is our major, a
minor (icons added) our minor, a patch (paths and metadata) our patch; our
own API changes follow SemVer as usual. `docs/releasing.md` has the
procedure: `changelog.sh --assemble X.Y.Z YYYY-MM-DD` on a release branch,
merge, then the owner tags `vX.Y.Z` on `main`; `release.yml` checks the tag
against the changelog, runs the tests and makes a **draft** release, which
the owner reads and publishes. Immutable releases are on: a published
release and its tag never change, so a mistake is fixed with a new patch
release. Swift Package Index picks up the tag by itself.
