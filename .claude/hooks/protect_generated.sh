#!/usr/bin/env bash
# .claude/hooks/protect_generated.sh
#
# Claude Code PreToolUse hook (matcher: Write|Edit|NotebookEdit). Refuses a
# hand edit of the generated icons and of their pin: both come from
# scripts/dev/update-icons.sh, which checks the npm package's sha512 and
# that every SVG is rebuilt byte for byte. A hand edit would be lost on the
# next update and could ship an icon that differs from Simple Icons. Change
# Tools/IconGenerator instead and run the script. Exit 2 blocks the call.

set -euo pipefail

payload="$(cat)"
if command -v jq >/dev/null 2>&1; then
  file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"
else
  file_path="$(printf '%s' "$payload" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
fi

case "${file_path:-}" in
*/Sources/SimpleIcons/Generated/* | */simple-icons.json)
  echo "BLOCKED: ${file_path##*/} is generated. Change Tools/IconGenerator and run bash scripts/dev/update-icons.sh (CLAUDE.md, Icons)." >&2
  exit 2
  ;;
esac

exit 0
