#!/usr/bin/env bash
# memory-guard: non-blocking PreToolUse reminder for auto-memory writes.
# Reads PreToolUse JSON from stdin, inspects tool_input.file_path,
# emits a checklist to stderr when the path is under ~/.claude/projects/*/memory/.
#
# Part of claude-continuity-kit — https://github.com/reallyunintented/claude-continuity-kit

input=$(cat)
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [[ "$path" == */.claude/projects/*/memory/* ]]; then
  cat >&2 <<'EOF'
[memory-guard] Auto-memory write detected. Before continuing, verify:
  1) Authoritative source re-read this session?
  2) Claim verifiable right now (not just plausible from old memory)?
  3) Entry minimal — no duplication of repo CLAUDE.md content?
  4) If correcting a claim already corrected once this session — re-read from scratch, don't patch.
EOF
fi

exit 0
