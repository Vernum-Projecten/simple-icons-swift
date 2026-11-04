#!/usr/bin/env bash
# SPDX-FileCopyrightText: simple-icons-swift contributors
# SPDX-License-Identifier: MIT
# scripts/dev/update-icons.sh: brings the icons in step with a simple-icons
# release.
#
# Downloads the simple-icons npm package, checks it against the sha512 the
# npm registry publishes (or the one pinned in simple-icons.json), and
# regenerates Sources/SimpleIcons/Generated/ with Tools/IconGenerator. Then
# writes the version and the checksum to simple-icons.json, the file the
# simple-icons README's version badge reads.
#
# Usage:
#   update-icons.sh              Regenerates from the version pinned in
#                                simple-icons.json (CI uses this to prove
#                                the generated code matches the pin).
#   update-icons.sh --latest     Moves to the latest simple-icons release.
#   update-icons.sh X.Y.Z        Moves to that simple-icons release.
#   update-icons.sh --check      Prints the latest release and exits 0 when
#                                the pin is it, 1 when an update exists.
#
# Needs curl, jq, tar, openssl and Swift. Exit 2 on a usage error.

set -euo pipefail
export LC_ALL=C

root="$(cd "$(dirname "$0")/../.." && pwd)"
readonly root
readonly PIN="$root/simple-icons.json"
readonly REGISTRY=https://registry.npmjs.org/simple-icons

die() {
  echo "update-icons: $*" >&2
  exit 1
}

pinned() { jq -r ".$1" "$PIN"; }
latest() { curl -fsSL --proto '=https' "$REGISTRY/latest" | jq -r .version; }

case "${1:-}" in
  "")
    version="$(pinned simpleIconsVersion)"
    integrity="$(pinned integrity)"
    ;;
  --latest)
    version="$(latest)"
    integrity=""
    ;;
  --check)
    current="$(pinned simpleIconsVersion)"
    newest="$(latest)"
    echo "$newest"
    [[ "$current" == "$newest" ]]
    exit
    ;;
  [0-9]*.[0-9]*.[0-9]*)
    version="$1"
    integrity=""
    ;;
  *)
    sed -n '/^# Usage:/,/^$/p' "$0" | sed 's/^# \{0,1\}//' >&2
    exit 2
    ;;
esac
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "'$version' is not a simple-icons version"

metadata="$(curl -fsSL --proto '=https' "$REGISTRY/$version")" || die "npm has no simple-icons $version"
published="$(jq -r .dist.integrity <<<"$metadata")"
tarball="$(jq -r .dist.tarball <<<"$metadata")"
# The pin and the registry must agree: a republished tarball is a red flag.
if [[ -n "$integrity" && "$integrity" != "$published" ]]; then
  die "simple-icons $version: the registry says $published, simple-icons.json pins $integrity"
fi
[[ "$tarball" == https://registry.npmjs.org/* ]] || die "unexpected tarball address $tarball"

work="$(mktemp -d)"
trap 'rm -r -- "$work"' EXIT
curl -fsSL --proto '=https' -o "$work/package.tgz" "$tarball"
actual="sha512-$(openssl dgst -sha512 -binary "$work/package.tgz" | openssl base64 -A)"
[[ "$actual" == "$published" ]] || die "simple-icons $version: download is $actual, expected $published"

# Unpacked into a folder of its own; the generator only reads it.
mkdir "$work/unpacked"
tar -xzf "$work/package.tgz" -C "$work/unpacked"

swift run --quiet --package-path "$root/Tools/IconGenerator" generate-icons \
  "$work/unpacked/package" "$root/Sources/SimpleIcons/Generated"

jq -n --arg version "$version" --arg integrity "$published" \
  '{simpleIconsVersion: $version, integrity: $integrity}' >"$PIN"
echo "update-icons: simple-icons $version ($published)."
