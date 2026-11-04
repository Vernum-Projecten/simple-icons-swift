# Contributing to simple-icons-swift

Thanks for helping. A contribution that follows this page is the one that
lands quickest.

- **A new icon, or a wrong one:** not here. The icons come unchanged from
  [Simple Icons](https://github.com/simple-icons/simple-icons); request or
  fix the icon there, and this package picks it up with the next release.
- **A bug or an idea for the package:** open an
  [issue](https://github.com/Vernum-Projecten/simple-icons-swift/issues/new/choose).
- **A vulnerability:** never in a public issue. Follow [SECURITY.md](SECURITY.md).
- **A larger change** (new public API, a new module): open an issue first
  and agree on the design, so nobody writes a pull request that cannot be
  merged. Public API is hard to take back.

Everyone here follows the [Code of Conduct](CODE_OF_CONDUCT.md). Using AI
tools is fine; [AI_POLICY.md](AI_POLICY.md) says what that asks of you.

## Set up

You need Xcode 27 (Swift 6.4) for the full gates; the package itself builds
with Swift 6.2 and later.

```bash
git clone https://github.com/Vernum-Projecten/simple-icons-swift.git
cd simple-icons-swift
git config core.hooksPath .githooks   # refuses secrets, cleans commit messages
open Package.swift                     # or: xed .
```

[CLAUDE.md](CLAUDE.md) maps the repository and holds the project's rules;
[.claude/rules/swift.md](.claude/rules/swift.md) is the Swift style guide,
built on the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
and Apple's guidance. Both apply to every contributor, human or agent.

## Run the gates

Run what CI runs before you push. Warnings are errors.

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift build -Xswiftc -warnings-as-errors
swift test -Xswiftc -warnings-as-errors
bash scripts/dev/format.sh --check     # bash scripts/dev/format.sh fixes it
shellcheck --severity=style scripts/*/*.sh .claude/hooks/*.sh .githooks/*
actionlint
bash scripts/release/changelog.sh --check
```

A change to the generator, to `SimpleIcon` or to the package layout also
runs the size check, which builds `Examples/SizeProbe` in release and fails
when an app with six icons grows past 1 MiB or contains an icon it does not
use:

```bash
bash scripts/checks/size-probe.sh
```

A change to `SimpleIconsSwiftUI` also builds for the other platforms:

```bash
for p in iOS tvOS watchOS visionOS; do
  xcodebuild build -quiet -scheme simple-icons-swift-Package -destination "generic/platform=$p"
done
```

## What a change needs

- **Tests**, in Swift Testing, in the target that mirrors the code. Never
  weaken, skip or delete a test to make a build pass.
- **Documentation** for every public declaration; `swift format` fails
  without it.
- **A changelog fragment.** A change a user of the package notices adds one
  file under `changelog.d/`, as [changelog.d/README.md](changelog.d/README.md)
  describes; never a line under `[Unreleased]` in `CHANGELOG.md`. A change
  nobody notices (a refactor, tests, CI, docs) gets the `no-changelog`
  label instead; say so in the pull request and a maintainer adds it.
- **No hand edits of the generated icons.** `Sources/SimpleIcons/Generated/`
  and `simple-icons.json` come from `scripts/dev/update-icons.sh`
  ([docs/updating-icons.md](docs/updating-icons.md)).
- **No secrets.** The pre-commit hook refuses keys and tokens.

## Branches, commits and pull requests

- Branch from `main` with a conventional type: `fix/…`, `feat/…`, `docs/…`,
  `refactor/…`, `test/…`, `perf/…`, `ci/…` or `chore/…`.
- Commit subjects are English conventional commits (`fix: …`, `feat: …`).
- One pull request does one thing. Its description says what changed and
  why, and links the issue (`Closes #123`).
- No AI or assistant attribution in commits or pull requests: no
  `Co-authored-by` for a tool, no "Generated with" line.

## License of your contribution

simple-icons-swift is licensed under the [MIT License](LICENSE). Anything
you submit for inclusion is licensed under the same terms, with no further
agreement. There is no CLA and no DCO sign-off: opening a pull request is
enough. Submit only work you have the right to license this way.
