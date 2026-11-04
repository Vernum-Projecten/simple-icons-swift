#!/usr/bin/env bash
# SPDX-FileCopyrightText: simple-icons-swift contributors
# SPDX-License-Identifier: MIT
# scripts/release/notes.sh vX.Y.Z
#
# Prints the CHANGELOG.md section of the version, without blank lines at
# the start and end: the text of the GitHub release. From Pullwatch, which
# took it from FerroLICENCE.
#
# A list item wrapped over several lines in CHANGELOG.md is joined onto one
# line: GitHub renders every line break in a release as a hard break, so a
# wrapped entry would break mid-sentence (it did in 1.0.0). A nested list
# item (indented "- " or "* ") stays on its own line.

set -euo pipefail

tag="${1:?usage: notes.sh vX.Y.Z}"
version="${tag#v}"
here="$(cd "$(dirname "$0")" && pwd)"

# The section runs to the next version heading or the link references below.
awk -v v="$version" '
  index($0, "## [" v "]") == 1 { on = 1; next }
  on && (/^## \[/ || /^\[[^]]+\]: /) { exit }
  on && !started && /^[[:space:]]*$/ { next }
  on { started = 1; print }
' "$here/../../CHANGELOG.md" | awk '
  # A continuation: indented, and not a nested list item.
  held != "" && /^[[:space:]]+[^[:space:]]/ && !/^[[:space:]]+[-*] / {
    line = $0
    sub(/^[[:space:]]+/, "", line)
    held = held " " line
    next
  }
  { if (held != "") print held; held = $0; if (held == "") { print ""; held = "" } }
  END { if (held != "") print held }
' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}'
