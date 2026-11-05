#!/usr/bin/env bash
# SPDX-FileCopyrightText: simple-icons-swift contributors
# SPDX-License-Identifier: MIT
# scripts/checks/size-probe.sh: proves that an app contains only the icons it
# names (#12, #13, #17).
#
# Builds Examples/SizeProbe in release, the way an app is built (SwiftPM
# strips unused code by default), and fails when:
#   - a probe binary, unstripped and with its symbol table and export trie
#     (__LINKEDIT), is larger than the limit (384 KiB on macOS, 512 KiB on
#     Linux; six icons take about 0.15 MiB on macOS and 0.35 MiB on Linux,
#     every icon about 6 MiB),
#   - it exports more than 500 symbols (about 150 today; a symbol per icon,
#     such as a property descriptor, makes it 3,600, #17),
#   - the path of an icon the probe does not use is in the binary, or
#   - the path of an icon it uses is not (the check would prove nothing).
# SizeProbeUI (SimpleIconsSwiftUI) is measured where SwiftUI exists.
#
# Usage:
#   size-probe.sh
#   SIZE_PROBE_PACKAGE=/path/to/simple-icons-swift size-probe.sh
#       Measures another copy of the package (Examples/SizeProbe reads the
#       variable), to prove the check fails on a build that keeps every icon.
#
# Writes a table to stdout, and to $GITHUB_STEP_SUMMARY in GitHub Actions.
# Exit 0 when every check passes, 1 otherwise.

set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
readonly root
if [[ "$(uname -s)" == Darwin ]]; then
  readonly LIMIT=$((384 * 1024))
else
  readonly LIMIT=$((512 * 1024))
fi
readonly SYMBOL_LIMIT=500
# An icon no probe uses (A-Frame, the first in Simple Icons' order after the
# digits) and one every probe uses (GitHub): the start of each path.
readonly UNUSED_SLUG=aframe
readonly USED_SLUG=github

# The first 24 characters of an icon's path, from the generated source.
path_start() {
  grep -h -A12 "public static func $1() -> SimpleIcon" "$root"/Sources/SimpleIcons/Generated/*.swift |
    sed -n 's/^ *path: "\(.\{24\}\).*/\1/p' | head -n 1
}
unused="$(path_start "$UNUSED_SLUG")"
used="$(path_start "$USED_SLUG")"
[[ -n "$unused" && -n "$used" ]] || {
  echo "size-probe: cannot find the paths of $UNUSED_SLUG and $USED_SLUG in Sources/SimpleIcons/Generated" >&2
  exit 1
}

scratch="$(mktemp -d)"
trap 'rm -r -- "$scratch"' EXIT
swift build --package-path "$root/Examples/SizeProbe" -c release --scratch-path "$scratch"

products=(SizeProbe)
if [[ "$(uname -s)" == Darwin ]]; then products+=(SizeProbeUI); fi

failed=0
table="| Probe | Platform | Size | Limit | Exported symbols | $UNUSED_SLUG (unused) in binary | $USED_SLUG (used) in binary |
| :-- | :-- | --: | --: | --: | :-: | :-: |"
for product in "${products[@]}"; do
  binary="$scratch/release/$product"
  size="$(wc -c <"$binary" | tr -d ' ')"
  has_unused="$(grep -a -c -F -- "$unused" "$binary" || true)"
  has_used="$(grep -a -c -F -- "$used" "$binary" || true)"
  if [[ "$(uname -s)" == Darwin ]]; then
    symbols="$(nm -gU "$binary" | wc -l | tr -d ' ')"
  else
    symbols="$(nm -g --defined-only "$binary" | wc -l | tr -d ' ')"
  fi
  table+="
| $product | $(uname -s) $(uname -m) | $size bytes | $LIMIT bytes | $symbols | $([[ "$has_unused" -eq 0 ]] && echo no || echo '**yes**') | $([[ "$has_used" -gt 0 ]] && echo yes || echo '**no**') |"
  if ((size > LIMIT)); then
    echo "size-probe: $product is $size bytes, over the limit of $LIMIT: icons the program does not use are in it (#12)." >&2
    failed=1
  fi
  if ((symbols > SYMBOL_LIMIT)); then
    echo "size-probe: $product exports $symbols symbols, over the limit of $SYMBOL_LIMIT: the library exports a symbol per icon (#17)." >&2
    failed=1
  fi
  if [[ "$has_unused" -ne 0 ]]; then
    echo "size-probe: $product contains the path of $UNUSED_SLUG, which it does not use: every icon is compiled in (#12)." >&2
    failed=1
  fi
  if [[ "$has_used" -eq 0 ]]; then
    echo "size-probe: $product does not contain the path of $USED_SLUG, which it uses; the check cannot see paths in this binary." >&2
    failed=1
  fi
done

echo "$table"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  printf '### App size with six icons\n\n%s\n' "$table" >>"$GITHUB_STEP_SUMMARY"
fi
if ((failed)); then exit 1; fi
echo "size-probe: an app contains only the icons it names."
