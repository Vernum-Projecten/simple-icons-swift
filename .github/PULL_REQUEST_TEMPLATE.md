## What changed and why

<!-- Describe the change and the reason for it. Keep it to what a reviewer needs. -->

Closes #NNN

## Checklist

- [ ] The gates in [CONTRIBUTING.md](https://github.com/Vernum-Projecten/simple-icons-swift/blob/main/CONTRIBUTING.md#run-the-gates) pass (`swift test`, `swift format`, shellcheck, actionlint, the changelog check).
- [ ] A changelog fragment in `changelog.d/`, or the `no-changelog` label for a change no user of the package notices.
- [ ] Every new public declaration is documented, and the API follows the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- [ ] No public symbol is removed or renamed, or the pull request has the `breaking` label.
- [ ] No hand edit of `Sources/SimpleIcons/Generated/` or `simple-icons.json` (`scripts/dev/update-icons.sh` makes them).
- [ ] No AI or assistant attribution anywhere in the commits or this pull request.
