#!/usr/bin/env bash
# claude-memory-kit installer.
# Copies the skill and hook into ~/.claude/ and prints snippets to merge manually.
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

echo "Installing claude-memory-kit..."
echo ""

# Preflight
if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required but not installed."
    echo "  Debian/Ubuntu: sudo apt install jq"
    echo "  macOS:         brew install jq"
    exit 1
fi

if [[ ! -d "${CLAUDE_DIR}" ]]; then
    echo "ERROR: ${CLAUDE_DIR} does not exist. Is Claude Code installed?"
    exit 1
fi

# Create dirs
mkdir -p "${CLAUDE_DIR}/skills/writing-memory"
mkdir -p "${CLAUDE_DIR}/hooks"

# Copy files
cp "${HERE}/skills/writing-memory/SKILL.md" "${CLAUDE_DIR}/skills/writing-memory/"
cp "${HERE}/hooks/memory-guard.sh" "${CLAUDE_DIR}/hooks/"
chmod +x "${CLAUDE_DIR}/hooks/memory-guard.sh"

echo "  Skill installed: ${CLAUDE_DIR}/skills/writing-memory/SKILL.md"
echo "  Hook installed:  ${CLAUDE_DIR}/hooks/memory-guard.sh (executable)"
echo ""
echo "---"
echo "Two manual merge steps remaining (these files are personal, we don't auto-edit them):"
echo ""
echo "STEP 1 — Merge into ${CLAUDE_DIR}/settings.json:"
echo ""
sed "s|\$HOME|${HOME}|g" "${HERE}/settings.snippet.json" | sed 's/^/    /'
echo ""
echo "  If you already have a 'hooks' key, merge the PreToolUse entry into your existing array."
echo ""
echo "STEP 2 — Append to ${CLAUDE_DIR}/CLAUDE.md (see ${HERE}/claude-md.snippet.md for the full text):"
echo ""
echo "    - If the user types \`verify first\` or \`source please\` (or similar hard-verify phrasing) at the start of a turn, treat it as an override: do not answer from memory, prior context, or assumption. Re-read the authoritative source before responding. Applies to that turn only."
echo ""
echo "---"
echo "Verify with: ./test.sh"
echo ""
echo "Done."
