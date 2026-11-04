#!/usr/bin/env bash
# SPDX-FileCopyrightText: simple-icons-swift contributors
# SPDX-License-Identifier: MIT
# scripts/release/notes.sh vX.Y.Z
#
# Prints the CHANGELOG.md section of the version, without blank lines at
# the start and end: the text of the GitHub release. From Pullwatch, which
# took it from FerroLICENCE.

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
' "$here/../../CHANGELOG.md" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}'
