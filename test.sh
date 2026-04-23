#!/usr/bin/env bash
# Test the memory-guard and session-reminder hooks.
# Usage: ./test.sh
set -uo pipefail

HOOK_MEMORY="./hooks/memory-guard.sh"
HOOK_SESSION="./hooks/session-reminder.sh"

for f in "$HOOK_MEMORY" "$HOOK_SESSION"; do
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
echo "Passed: $PASS, Failed: $FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
