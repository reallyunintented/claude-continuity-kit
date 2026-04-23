#!/usr/bin/env bash
# Test all hooks: memory-guard, session-reminder, handoff-surface.
# Usage: ./test.sh
set -uo pipefail

HOOK_MEMORY="./hooks/memory-guard.sh"
HOOK_SESSION="./hooks/session-reminder.sh"
HOOK_HANDOFF="./hooks/handoff-surface.sh"

for f in "$HOOK_MEMORY" "$HOOK_SESSION" "$HOOK_HANDOFF"; do
    if [[ ! -x "$f" ]]; then
        echo "ERROR: $f is not executable or does not exist."
        echo "Run: chmod +x $f"
        exit 1
    fi
done

if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required for the memory-guard hook to function."
    exit 1
fi

PASS=0
FAIL=0

run_memory_test() {
    local name="$1"
    local stdin_data="$2"
    local expect_checklist="$3"  # "yes" or "no"

    local out exit_code
    out=$(bash "$HOOK_MEMORY" <<<"$stdin_data" 2>&1)
    exit_code=$?

    local has_checklist="no"
    [[ "$out" == *"[memory-guard]"* ]] && has_checklist="yes"

    if [[ "$exit_code" -eq 0 ]] && [[ "$has_checklist" == "$expect_checklist" ]]; then
        echo "  PASS: $name"
        PASS=$((PASS+1))
    else
        echo "  FAIL: $name (exit=$exit_code, checklist=$has_checklist, expected=$expect_checklist)"
        FAIL=$((FAIL+1))
    fi
}

run_session_test() {
    local out exit_code
    out=$(bash "$HOOK_SESSION" </dev/null 2>&1)
    exit_code=$?

    if [[ "$exit_code" -eq 0 ]] && [[ "$out" == *"[memory-kit]"* ]]; then
        echo "  PASS: session-reminder emits on SessionStart"
        PASS=$((PASS+1))
    else
        echo "  FAIL: session-reminder (exit=$exit_code, output=$out)"
        FAIL=$((FAIL+1))
    fi
}

TMPHOME=""
cleanup_handoff() {
    [[ -n "${TMPHOME:-}" && -d "$TMPHOME" ]] && rm -rf "$TMPHOME"
}
trap cleanup_handoff EXIT

run_handoff_test() {
    local name="$1"
    local setup_cmd="$2"
    local expect_output="$3"  # "yes" or "no"

    TMPHOME=$(mktemp -d)
    rm -rf "$TMPHOME/.claude"
    mkdir -p "$TMPHOME/.claude/plans"
    eval "$setup_cmd"

    local out exit_code
    out=$(HOME="$TMPHOME" bash "$HOOK_HANDOFF" </dev/null 2>&1)
    exit_code=$?

    local has_output="no"
    [[ -n "$out" ]] && has_output="yes"

    if [[ "$exit_code" -eq 0 ]] && [[ "$has_output" == "$expect_output" ]]; then
        echo "  PASS: $name"
        PASS=$((PASS+1))
    else
        echo "  FAIL: $name (exit=$exit_code, output=$has_output, expected=$expect_output)"
        FAIL=$((FAIL+1))
    fi

    rm -rf "$TMPHOME"
    TMPHOME=""
}

echo "Testing memory-guard hook..."
echo ""

run_memory_test "memory path emits checklist" \
    '{"tool_input":{"file_path":"/home/x/.claude/projects/foo/memory/bar.md"}}' \
    "yes"

run_memory_test "non-memory path stays silent" \
    '{"tool_input":{"file_path":"/tmp/unrelated.md"}}' \
    "no"

run_memory_test "malformed JSON does not crash" \
    'not json at all' \
    "no"

run_memory_test "empty input does not crash" \
    '' \
    "no"

echo ""
echo "Testing session-reminder hook..."
echo ""

run_session_test

echo ""
echo "Testing handoff-surface hook..."
echo ""

run_handoff_test "fresh handoff surfaces" \
    "echo 'test handoff' > \"\$TMPHOME/.claude/plans/handoff-2026-04-23-topic.md\"" \
    "yes"

run_handoff_test "no plans dir stays silent" \
    "rm -rf \"\$TMPHOME/.claude/plans\"" \
    "no"

run_handoff_test "empty plans dir stays silent" \
    ":" \
    "no"

run_handoff_test "stale handoff (old mtime) stays silent" \
    "echo 'old' > \"\$TMPHOME/.claude/plans/handoff-2024-01-01-old.md\"; touch -d '30 days ago' \"\$TMPHOME/.claude/plans/handoff-2024-01-01-old.md\"" \
    "no"

run_handoff_test "unrelated files in plans dir ignored" \
    "echo 'not a handoff' > \"\$TMPHOME/.claude/plans/random.md\"" \
    "no"

echo ""
echo "Passed: $PASS, Failed: $FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
