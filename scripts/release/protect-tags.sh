#!/usr/bin/env bash
# SPDX-FileCopyrightText: simple-icons-swift contributors
# SPDX-License-Identifier: MIT
# scripts/release/protect-tags.sh [owner/repo]
#
# Creates (once) the repository ruleset that pins release tags: a v* tag can
# be neither deleted nor moved. SwiftPM and Swift Package Index resolve a
# version by its tag, so a moved tag would hand two apps different code for
# the same version. From Pullwatch, which took it from FerroLICENCE.
# Idempotent: exits 0 when a ruleset "release-tags" exists. Needs admin
# rights on the repository (docs/releasing.md).

set -euo pipefail

repo="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"

if gh api "repos/$repo/rulesets" --jq '.[].name' | grep -qx 'release-tags'; then
  echo "ok: ruleset 'release-tags' already exists on $repo"
  exit 0
fi

gh api --method POST "repos/$repo/rulesets" \
  --input - <<'JSON' >/dev/null
{
  "name": "release-tags",
  "target": "tag",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["refs/tags/v*"], "exclude": [] } },
  "rules": [
    { "type": "deletion" },
    { "type": "update" },
    { "type": "non_fast_forward" }
  ]
}
JSON
echo "ok: ruleset 'release-tags' created on $repo (v* tags: no delete, no move)"
