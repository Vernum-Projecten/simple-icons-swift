#!/usr/bin/env bash
# SPDX-FileCopyrightText: simple-icons-swift contributors
# SPDX-License-Identifier: MIT
# scripts/dev/format.sh: formats the hand-written Swift with `swift format`
# (part of the Swift toolchain) as .swift-format configures it.
#
# Usage:
#   format.sh            Rewrites the files in place.
#   format.sh --check    Changes nothing; exits 1 when a file is not
#                        formatted or breaks a lint rule (CI's gate).
#
# Sources/SimpleIcons/Generated/ is left out: the generator writes it, and
# its long path literals are data, not code to read.

set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"

files=(
  Examples/IconBrowser/Package.swift
  Examples/IconBrowser/Sources
  Examples/IconBrowser/Tests
  Package.swift
  Sources/SimpleIconsSwiftUI
  Tests
  Tools/IconGenerator/Package.swift
  Tools/IconGenerator/Sources
)
while IFS= read -r -d '' f; do files+=("$f"); done < <(
  find Sources/SimpleIcons -name '*.swift' -not -path 'Sources/SimpleIcons/Generated/*' -print0)

case "${1:-}" in
  "") swift format format --in-place --parallel --recursive "${files[@]}" ;;
  --check) swift format lint --strict --parallel --recursive "${files[@]}" ;;
  *)
    echo "usage: format.sh [--check]" >&2
    exit 2
    ;;
esac
