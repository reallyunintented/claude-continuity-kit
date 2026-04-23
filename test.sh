#!/usr/bin/env bash
# Test the memory-guard hook across scenarios.
# Usage: ./test.sh [path-to-hook-script]
set -uo pipefail

HOOK="${1:-./hooks/memory-guard.sh}"

if [[ ! -x "$HOOK" ]]; then
    echo "ERROR: $HOOK is not executable or does not exist."
    echo "Run: chmod +x $HOOK"
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required for the hook to function."
    exit 1
fi

PASS=0
FAIL=0

run_test() {
    local name="$1"
    local stdin_data="$2"
    local expect_checklist="$3"  # "yes" or "no"

    local out exit_code
    out=$(bash "$HOOK" <<<"$stdin_data" 2>&1)
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

echo "Testing ${HOOK}..."
echo ""

run_test "memory path emits checklist" \
    '{"tool_input":{"file_path":"/home/x/.claude/projects/foo/memory/bar.md"}}' \
    "yes"

run_test "non-memory path stays silent" \
    '{"tool_input":{"file_path":"/tmp/unrelated.md"}}' \
    "no"

run_test "malformed JSON does not crash" \
    'not json at all' \
    "no"

run_test "empty input does not crash" \
    '' \
    "no"

echo ""
echo "Passed: $PASS, Failed: $FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
