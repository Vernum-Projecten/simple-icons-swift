# Updating the icons

The icons come unchanged from the [simple-icons npm package](https://www.npmjs.com/package/simple-icons).
Nothing in `Sources/SimpleIcons/Generated/` or `simple-icons.json` is
edited by hand.

## How an update happens

Every day `.github/workflows/icons.yml` asks npm for the latest release.
When it is newer than the pin in `simple-icons.json`, the workflow:

1. runs `scripts/dev/update-icons.sh X.Y.Z`, which downloads the tarball,
   checks it against the sha512 the npm registry publishes, unpacks it into
   a temporary folder and runs `Tools/IconGenerator`;
2. builds and runs every test, so a release the package cannot take fails
   here and never becomes a pull request;
3. writes a changelog fragment (`changelog.d/0-simple-icons-X-Y-Z.changed.md`,
   and `.removed.md` listing the removed slugs when there are any);
4. pushes the branch `chore/simple-icons-update` and opens a pull request,
   or updates the open one, with the new and removed icons listed. One
   that removes icons carries the `breaking` label: the next release is a
   major one (`docs/releasing.md`).

Review the list of new and removed icons, let CI pass, and merge. Run the
workflow by hand (Actions, Icons, Run workflow) to update at once or to a
specific version.

### CI on the icon pull requests

GitHub does not start workflows for a pull request that the default
`GITHUB_TOKEN` opened. Two ways round it:

- Add an `ICONS_TOKEN` Actions secret: a fine-grained personal access
  token, or a GitHub App installation token, for this repository with
  **Contents: read and write** and **Pull requests: read and write**. The
  workflow then opens the pull request with it and CI runs as usual.
- Without it, close and reopen the pull request; the pull request says so.

## By hand

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
bash scripts/dev/update-icons.sh --check     # prints the latest; exit 1 when newer than the pin
bash scripts/dev/update-icons.sh --latest    # or: update-icons.sh 16.37.0
swift test
```

Without an argument the script regenerates the pinned version; CI uses that
to prove the committed code is exactly what the generator makes.

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
