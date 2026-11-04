# Releasing

A release is a `vX.Y.Z` tag on `main` and a GitHub release for it. A Swift
package ships as source: SwiftPM and Swift Package Index resolve a version
from its tag, so there is nothing to build, sign or upload. The owner
pushes the tag; `.github/workflows/release.yml` checks it, runs the tests
and **publishes** the release with the changelog section as notes. Nothing
is left to click.

> [!IMPORTANT]
> The repository has **immutable releases** on. A published release, its
> notes and its tag can never be changed or deleted. So the last chance to
> fix the notes is the release pull request (step 3), and pushing the tag
> is the decision to release.

## Versions

**The package's version is the version of the Simple Icons release it
holds.** simple-icons-swift 16.36.0 has the icons of Simple Icons 16.36.0,
so nobody has to look up which icons a version contains, and the version
column of the Simple Icons listing matches our releases. `check-version.sh`
refuses a tag that differs from `simpleIconsVersion` in `simple-icons.json`.

This is still Semantic Versioning, because Simple Icons'
[versioning](https://github.com/simple-icons/simple-icons/blob/develop/VERSIONING.md)
changes our public API the same way it changes theirs: every icon is a
public constant.

| Simple Icons release | What it does | For code using the package |
| :-- | :-- | :-- |
| Major | Removes icons, changes slugs | The removed constants are gone: code that used them stops compiling |
| Minor | Adds icons, changes titles | New constants; nothing breaks |
| Patch | Updates paths and metadata | Nothing breaks |

What follows from it:

- **One release per Simple Icons release**, soon after the icon update
  issue is done. Simple Icons releases weekly.
- **Our own changes ship with the next Simple Icons release.** A fix or a
  new API waits for the next weekly release; there is no version number
  of our own to give it.
- **Breaking API of our own waits for a Simple Icons major** (about every
  six months), the only releases that may break code. Until then, add
  next to the old API and deprecate it.
- **1.0.0** is the first release, made before this rule; it holds Simple
  Icons 16.36.0, the same code as 16.36.0. It stays as it is: releases and
  their tags are immutable.

Simple Icons supports only its latest major and the last release of the
one before, and its README lists only libraries that keep up with at least
the previous major: releasing with every Simple Icons release keeps the
listing's version column current.

## Once per repository

- `bash scripts/gh/labels.sh` creates the labels (`icons`, `breaking`,
  `no-changelog` and the work kinds).
- `bash scripts/release/protect-tags.sh` creates the ruleset that stops a
  `v*` tag from being moved or deleted: SwiftPM would otherwise hand two
  apps different code for the same version.

## Cut a release

1. The version is `simpleIconsVersion` in `simple-icons.json` on `main`,
   after the icon update is merged:
   `bash scripts/release/changelog.sh --preview X.Y.Z` prints the section.
2. On a branch `release/X.Y.Z`:

   ```bash
   bash scripts/release/changelog.sh --assemble X.Y.Z "$(date +%F)"
   ```

   It writes the fragments into `CHANGELOG.md` under `## [X.Y.Z] - date`
   and deletes them.
3. Open the pull request (`release: X.Y.Z`, label `no-changelog`), let CI
   pass, merge. **Read the section in the pull request carefully:** it
   becomes the release notes word for word, and they can never be edited
   after the release.
4. On the updated `main`:

   ```bash
   bash scripts/release/check-version.sh vX.Y.Z
   git tag -a vX.Y.Z -m "simple-icons-swift X.Y.Z"   # -s instead of -a to sign it
   git push origin vX.Y.Z
   ```

   (Claude sessions do not push tags or create, edit or publish releases;
   the hook refuses it.)
5. `release.yml` checks that the tag is on `main`, that `CHANGELOG.md` has
   its section and no fragment is left, that the icons match the pin, runs
   the tests on the tagged commit, and publishes the release
   "simple-icons-swift X.Y.Z" as the latest one. Swift Package Index finds
   the tag within a few hours.

## When a release goes wrong

- **The workflow failed on something passing** (a runner, the network):
  re-run the failed jobs from the run's page.
- **The workflow failed on the code or the changelog:** nothing was
  published. Fix it on `main` through a pull request. The version cannot
  move (it is the Simple Icons version), so the owner deletes the
  unpublished tag, as a repository admin past the `release-tags` ruleset,
  and tags the fixed `main` again. Do this only while no release exists
  for the tag.
- **A published release is wrong:** it is immutable. The fix ships with
  the next Simple Icons release.
