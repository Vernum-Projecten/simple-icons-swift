# Releasing

A release is a `vX.Y.Z` tag on `main`. A Swift package ships as source:
SwiftPM and Swift Package Index resolve a version from its tag, so there is
nothing to build, sign or upload. `.github/workflows/release.yml` checks the
tag and publishes the GitHub release with the changelog section as notes.

## Versions

Semantic Versioning of our own, starting at 1.0.0. The package's version
is not the Simple Icons version: that one is in `simple-icons.json`, in
`SimpleIcon.simpleIconsVersion` and in the README badge. Because every icon
is a public constant, a Simple Icons release changes our API the way its
own [versioning](https://github.com/simple-icons/simple-icons/blob/develop/VERSIONING.md)
says, so it folds into ours like this:

| Simple Icons release | What it does | Our release |
| :-- | :-- | :-- |
| Major | Removes icons, changes slugs | **Major**: those constants are gone, so code that used them stops compiling |
| Minor | Adds icons, changes titles | **Minor**: new constants, nothing breaks |
| Patch | Updates paths and metadata | **Patch** |

Our own changes follow SemVer as usual: removing or renaming public API, or
changing what it means, is a major release (the pull request carries the
`breaking` label); new API is a minor one; a fix is a patch. A release takes
the largest step any of its changes needs.

Simple Icons supports only its latest major and the last release of the
one before, and its README lists only libraries that keep up with at least
the previous major. Release soon after an icon update is merged, so the
listing's version column stays current.

## Once per repository

- `bash scripts/gh/labels.sh` creates the labels (`icons`, `breaking`,
  `no-changelog` and the work kinds).
- `bash scripts/release/protect-tags.sh` creates the ruleset that stops a
  `v*` tag from being moved or deleted: SwiftPM would otherwise hand two
  apps different code for the same version.
- Optional, so CI runs on the icon pull requests: an `ICONS_TOKEN` secret
  (`docs/updating-icons.md`).

## Cut a release

1. Decide the version from the table above and the open fragments:
   `bash scripts/release/changelog.sh --preview X.Y.Z` prints the section.
2. On a branch `release/X.Y.Z`:

   ```bash
   bash scripts/release/changelog.sh --assemble X.Y.Z "$(date +%F)"
   ```

   It writes the fragments into `CHANGELOG.md` under `## [X.Y.Z] - date`
   and deletes them. Read the section once more: it is what people see.
3. Open the pull request (`release: X.Y.Z`, label `no-changelog`), let CI
   pass, merge.
4. On the updated `main`:

   ```bash
   bash scripts/release/check-version.sh vX.Y.Z
   git tag -s vX.Y.Z -m "simple-icons-swift X.Y.Z"
   git push origin vX.Y.Z
   ```

   (Claude sessions do not push tags; the hook refuses it.)
5. `release.yml` checks that the tag is on `main`, that `CHANGELOG.md` has
   its section and no fragment is left, that the icons match the pin, runs
   the tests, and publishes the release. Swift Package Index finds the tag
   within a few hours.

## When a release goes wrong

A published tag is never moved or deleted (the ruleset refuses it anyway).
Fix forward: a new patch release with the fix.
