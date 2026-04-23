# writing-memory

Use this skill whenever about to Write, Edit, or delete a file under `~/.claude/projects/*/memory/`, or when about to assert a memory-sourced claim about a project, user trait, or system state in a response.

## Goal

Prevent stale, wordy, or unverified memory entries from accumulating.

## Checklist

Before writing to or asserting from memory:

1. Did I re-read the authoritative source this session? (Repo's own `CLAUDE.md`, the file being described, or any curated insights/status doc the user maintains.)
2. Is the claim verifiable right now? If not, verify before writing.
3. Is this the minimum entry needed for disambiguation or calibration? Do not duplicate architecture, stack, commands, or paths from the repo's own `CLAUDE.md` — the duplicate will drift.
4. If correcting an existing memory entry: has the user corrected this same claim twice in one session? If yes, the premise itself is wrong — re-read from scratch, do not patch.

## Output

- State which source was verified before writing.
- After the write, announce the file path and a one-line summary of what changed.
- Keep prose terse; long narrative in memory is drift-bait.
