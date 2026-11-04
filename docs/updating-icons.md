# Updating the icons

The icons come unchanged from the [simple-icons npm package](https://www.npmjs.com/package/simple-icons).
Nothing in `Sources/SimpleIcons/Generated/` or `simple-icons.json` is
edited by hand.

## How an update happens

Two steps, on purpose kept apart:

1. **The workflow notices.** Every day `.github/workflows/icons.yml` asks
   npm for the latest release. When it is newer than the pin in
   `simple-icons.json`, it downloads both releases' tarballs, checks each
   against the sha512 the registry publishes, and opens an issue "Update
   the icons to Simple Icons X.Y.Z" listing the new and removed icons
   (labels `icons`, and `breaking` when icons are removed). When such an
   issue is already open, it moves that one to the newest version instead
   of opening another. Run it by hand from Actions, Icons, Run workflow.
2. **A person (or a Claude session) updates.** The workflow writes no code
   and opens no pull request: it runs with the workflow's own token and
   `issues: write` only, so no extra token with write access to the code
   exists anywhere. The update goes through a pull request like every
   other change, with CI running as usual.

## Doing an update issue

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
git switch -c chore/simple-icons-X.Y.Z main
bash scripts/dev/update-icons.sh X.Y.Z       # or --latest
swift test -Xswiftc -warnings-as-errors      # and the other gates
```

`update-icons.sh` downloads the tarball, checks its sha512, regenerates
`Sources/SimpleIcons/Generated/`, writes `simple-icons.json`, and writes
the changelog fragments: `changelog.d/0-simple-icons-X-Y-Z.changed.md`,
and `.removed.md` listing the removed slugs when there are any. Then open a
pull request that closes the issue, labelled `icons` (and `breaking` when
icons are removed): the next release is then a major one
(`docs/releasing.md`).

`--check` prints the latest release and exits 1 when it is newer than the
pin. Without an argument the script regenerates the pinned version and
writes no fragment; CI uses that to prove the committed code is exactly
what the generator makes.

## When the generator refuses

The generator stops, and writes nothing, when the data does not fit what
the package promises. Each message says what to change:

- **"icons/x.svg is not the SVG that SimpleIcon.svg rebuilds"**: Simple
  Icons changed how it writes its SVG files (an attribute, the escaping of
  the title). Change `SimpleIcon+SVG.swift` and the matching code in the
  generator together, so `svg` stays the upstream file byte for byte.
- **"slug 'x' is not lowercase ASCII letters, digits and underscores"** or
  **"would clash with a member of SimpleIcon"**: a slug that cannot be a
  Swift name as it is. Decide on a naming rule in `swiftName(for:)`; that
  is a change to the public API, so it is its own pull request.
- **"has a custom license without an address"** or **"an SPDX license with
  an address"**: a new shape of license data. Model it in
  `SimpleIcon.License` (a new case is a minor release) and the generator.
- A path that does not parse fails the test `Every icon parses completely`:
  the parser in `Sources/SimpleIcons/Path/` misses part of the SVG path
  grammar. Fix the parser, never the icon.
