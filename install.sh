#!/usr/bin/env bash
# claude-continuity-kit installer.
# Copies skills, hooks, and slash commands into ~/.claude/ and prints snippets to merge manually.
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

echo "Installing claude-continuity-kit..."
echo ""

# Preflight
if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required but not installed (used by memory-guard hook)."
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
mkdir -p "${CLAUDE_DIR}/skills/writing-handoff"
mkdir -p "${CLAUDE_DIR}/hooks"
mkdir -p "${CLAUDE_DIR}/commands"
mkdir -p "${CLAUDE_DIR}/plans"

# Memory kit
cp "${HERE}/skills/writing-memory/SKILL.md"  "${CLAUDE_DIR}/skills/writing-memory/"
cp "${HERE}/hooks/memory-guard.sh"           "${CLAUDE_DIR}/hooks/"
cp "${HERE}/hooks/session-reminder.sh"       "${CLAUDE_DIR}/hooks/"
cp "${HERE}/commands/verify.md"              "${CLAUDE_DIR}/commands/"
chmod +x "${CLAUDE_DIR}/hooks/memory-guard.sh" "${CLAUDE_DIR}/hooks/session-reminder.sh"

# Handoff kit
cp "${HERE}/skills/writing-handoff/SKILL.md" "${CLAUDE_DIR}/skills/writing-handoff/"
cp "${HERE}/hooks/handoff-surface.sh"        "${CLAUDE_DIR}/hooks/"
cp "${HERE}/hooks/session-snapshot.sh"       "${CLAUDE_DIR}/hooks/"
cp "${HERE}/commands/handoff.md"             "${CLAUDE_DIR}/commands/"
chmod +x "${CLAUDE_DIR}/hooks/handoff-surface.sh" "${CLAUDE_DIR}/hooks/session-snapshot.sh"

echo "  Memory kit:"
echo "    skill:    ${CLAUDE_DIR}/skills/writing-memory/SKILL.md"
echo "    hook:     ${CLAUDE_DIR}/hooks/memory-guard.sh"
echo "    hook:     ${CLAUDE_DIR}/hooks/session-reminder.sh"
echo "    command:  ${CLAUDE_DIR}/commands/verify.md  (type /verify)"
echo ""
echo "  Handoff kit:"
echo "    skill:    ${CLAUDE_DIR}/skills/writing-handoff/SKILL.md"
echo "    hook:     ${CLAUDE_DIR}/hooks/handoff-surface.sh"
echo "    hook:     ${CLAUDE_DIR}/hooks/session-snapshot.sh"
echo "    command:  ${CLAUDE_DIR}/commands/handoff.md  (type /handoff)"
echo ""
echo "  Plans dir ensured: ${CLAUDE_DIR}/plans/"
echo ""
echo "---"
echo "Two manual merge steps remaining (these files are personal, we don't auto-edit them):"
echo ""
echo "STEP 1 — Merge into ${CLAUDE_DIR}/settings.json:"
echo ""
sed "s|\$HOME|${HOME}|g" "${HERE}/settings.snippet.json" | sed 's/^/    /'
echo ""
echo "  If you already have a 'hooks' key, merge the PreToolUse + SessionStart entries into your existing structure."
echo "  Note: both SessionStart hooks coexist — one for memory discipline, one for handoff surfacing."
echo ""
echo "STEP 2 — Append the relevant sections from ${HERE}/claude-md.snippet.md to ${CLAUDE_DIR}/CLAUDE.md."
echo "  Memory half: shortcut rule + Auto-Memory Discipline section."
echo "  Handoff half: Handoff Discipline section."
echo ""
echo "---"
echo "Verify with: ./test.sh"
echo ""
echo "Done."
