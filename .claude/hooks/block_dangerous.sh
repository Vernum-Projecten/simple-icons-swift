#!/usr/bin/env bash
# .claude/hooks/block_dangerous.sh
#
# Claude Code PreToolUse hook (matcher: Bash). Refuses:
#   - rm -rf outside the temp directory
#   - force-pushes touching main, and bare force-pushes
#   - a pull request or issue in simple-icons/simple-icons: the request to
#     be listed among the third-party libraries is the owner's to open
#     (docs/third-party-listing.md)
#   - a release tag pushed, or a GitHub release created, edited or deleted:
#     the repository has immutable releases, so publishing is final and the
#     owner's (docs/releasing.md)
#   - security commands that would export or delete signing identities

set -euo pipefail

payload="$(cat)"
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
else
  cmd="$payload"
fi
[ -n "${cmd:-}" ] || exit 0

if printf '%s' "$cmd" | grep -qE '(^|[;&|[:space:]])rm[[:space:]]+-[a-zA-Z]*([rR][a-zA-Z]*f|f[a-zA-Z]*[rR])'; then
  # shellcheck disable=SC2016 # the literal `$TMPDIR` is a grep pattern, not an expansion
  if ! printf '%s' "$cmd" | grep -qE 'rm[[:space:]]+-[a-zA-Z]+[[:space:]]+"?(/private)?/tmp/|\$TMPDIR'; then
    echo "BLOCKED: 'rm -rf' is not allowed outside the temp directory." >&2
    exit 2
  fi
fi

if printf '%s' "$cmd" | grep -qE 'git[[:space:]]+push[^;|&]*(--force([^-]|$)|--force-with-lease|[[:space:]]-f([[:space:]]|$)|[[:space:]]\+[[:alnum:]])'; then
  if printf '%s' "$cmd" | grep -qE '(^|[[:space:]:/+])(main|master)([[:space:]]|$|["'"'"';&|])'; then
    echo "BLOCKED: force-push touching main is forbidden." >&2
    exit 2
  fi
  if ! printf '%s' "$cmd" | grep -qE '(feat|fix|chore|docs|refactor|perf|test|ci|build|release)/'; then
    echo "BLOCKED: bare force-push refused; name a conventional-type branch." >&2
    exit 2
  fi
fi

if printf '%s' "$cmd" | grep -qE 'gh[[:space:]]+(pr|issue)[[:space:]]+create[^;|&]*(--repo|-R)[[:space:]=]+simple-icons/simple-icons'; then
  echo "BLOCKED: the owner opens pull requests and issues in simple-icons/simple-icons. Prepare the text from docs/third-party-listing.md and hand it over." >&2
  exit 2
fi

if printf '%s' "$cmd" | grep -qE 'git[[:space:]]+push[^;|&]*[[:space:]](refs/tags/)?v[0-9]+\.[0-9]+\.[0-9]+|git[[:space:]]+push[^;|&]*--tags'; then
  echo "BLOCKED: release tags are the owner's; follow docs/releasing.md." >&2
  exit 2
fi

if printf '%s' "$cmd" | grep -qE 'gh[[:space:]]+release[[:space:]]+(create|edit|delete|upload)'; then
  echo "BLOCKED: releases are immutable once published; the Release workflow makes the draft and the owner publishes it (docs/releasing.md)." >&2
  exit 2
fi

if printf '%s' "$cmd" | grep -qE 'security[[:space:]]+(export|delete-identity|delete-certificate|delete-keychain)'; then
  echo "BLOCKED: exporting or deleting signing identities is the owner's job, never a session's." >&2
  exit 2
fi

exit 0
