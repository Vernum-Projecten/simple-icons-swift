#!/usr/bin/env bash
# SPDX-FileCopyrightText: simple-icons-swift contributors
# SPDX-License-Identifier: MIT
# scripts/release/check-version.sh vX.Y.Z
#
# Run by release.yml before anything is published, and by hand before the
# owner tags: the tag is SemVer, CHANGELOG.md has a dated section for it
# that is not empty, no changelog fragment is left behind, the icons
# match the pin, and the version is the Simple Icons version they hold.
# Exit 0 when everything agrees, 1 otherwise.

set -euo pipefail

tag="${1:?usage: check-version.sh vX.Y.Z}"
if ! [[ "$tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  echo "tag '$tag' is not vX.Y.Z" >&2
  exit 1
fi
version="${BASH_REMATCH[1]}"

here="$(cd "$(dirname "$0")" && pwd)"
cd "$here/../.."

if ! grep -qE "^## \[${version//./\\.}\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$" CHANGELOG.md; then
  echo "CHANGELOG.md has no '## [$version] - YYYY-MM-DD' section; run scripts/release/changelog.sh --assemble $version YYYY-MM-DD first" >&2
  exit 1
fi
if [ -z "$(bash "$here/notes.sh" "$tag")" ]; then
  echo "the CHANGELOG.md section for $version is empty; it becomes the release notes" >&2
  exit 1
fi

# The cut (changelog.sh --assemble) writes the fragments into CHANGELOG.md
# and deletes them; one that is still here would be missing from the notes.
left="$(find changelog.d -maxdepth 1 -type f -name '*.md' ! -name README.md | sort)"
if [ -n "$left" ]; then
  echo "changelog.d/ still holds fragments; run scripts/release/changelog.sh --assemble $version YYYY-MM-DD on the release branch first:" >&2
  echo "$left" >&2
  exit 1
fi

# The generated code says which simple-icons it holds; it must be the pin.
pinned="$(jq -r .simpleIconsVersion simple-icons.json)"
generated="$(sed -n 's/^ *public static let simpleIconsVersion = "\(.*\)"$/\1/p' Sources/SimpleIcons/Generated/SimpleIcon+AllCases.swift)"
if [ "$pinned" != "$generated" ]; then
  echo "simple-icons.json pins $pinned but the generated icons are from $generated; run bash scripts/dev/update-icons.sh" >&2
  exit 1
fi

# MAJOR.MINOR is the Simple Icons release the package holds; PATCH is ours,
# the next free number (docs/releasing.md, Versions).
if [ "${version%.*}" != "${pinned%.*}" ]; then
  echo "tag $tag, but the package holds Simple Icons $pinned: the version starts with its MAJOR.MINOR, ${pinned%.*} (docs/releasing.md, Versions)" >&2
  exit 1
fi
patch="${version##*.}"
highest="$(git tag -l "v${version%.*}.*" | grep -vx "$tag" | sed 's/^v[0-9]*\.[0-9]*\.//' | grep -E '^[0-9]+$' | sort -n | tail -n 1 || true)"
if [ -n "$highest" ] && [ "$patch" -le "$highest" ]; then
  echo "tag $tag, but v${version%.*}.$highest exists: the next patch is ${version%.*}.$((highest + 1)) (docs/releasing.md, Versions)" >&2
  exit 1
fi

echo "ok: $tag has its CHANGELOG.md section, no fragment is left, and holds Simple Icons $pinned"
