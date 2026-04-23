#!/usr/bin/env bash
# session-reminder: fires at SessionStart, prints a brief memory-discipline note.
# Front-loads the rules so the first reminder isn't mid-action.
#
# Part of claude-continuity-kit — https://github.com/reallyunintented/claude-continuity-kit

cat >&2 <<'EOF'
[memory-kit] Auto-memory discipline active.
  - Verify sources before asserting from memory.
  - Memory is for disambiguation, not architecture duplication.
  - If corrected twice on the same claim — re-read from source, don't patch.
EOF

exit 0
