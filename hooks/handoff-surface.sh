#!/usr/bin/env bash
# handoff-surface: SessionStart hook that surfaces the most recent handoff
# file from ~/.claude/plans/ when one exists and is reasonably fresh.
#
# - Silent when no handoff files exist.
# - Silent when the newest handoff is older than HANDOFF_MAX_AGE_DAYS (default 14).
# - Emits the handoff to stderr so the runtime injects it as SessionStart context.
#
# Part of claude-continuity-kit — https://github.com/reallyunintented/claude-continuity-kit

set -u

PLANS_DIR="${HOME}/.claude/plans"
MAX_AGE_DAYS="${HANDOFF_MAX_AGE_DAYS:-14}"

[[ -d "$PLANS_DIR" ]] || exit 0

# Newest handoff-*.md file, filtered by mtime within MAX_AGE_DAYS.
newest=$(find "$PLANS_DIR" -maxdepth 1 -type f -name 'handoff-*.md' \
    -mtime "-${MAX_AGE_DAYS}" -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr | head -n1 | cut -d' ' -f2-)

[[ -n "$newest" && -r "$newest" ]] || exit 0

{
    echo "[handoff-kit] Pending handoff from previous session: $(basename "$newest")"
    echo ""
    cat "$newest"
    echo ""
    echo "[handoff-kit] Read the handoff before taking action. Delete the file after the handoff is executed or superseded."
} >&2

exit 0
