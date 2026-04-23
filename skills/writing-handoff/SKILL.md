---
name: writing-handoff
description: Use when a topic closes, the session enters wait-state, or the user says a handoff trigger phrase ("wrap up", "done for now", "handoff", "pick this up later"). Produces a compact file at ~/.claude/plans/handoff-YYYY-MM-DD-<topic>.md that lets the next session resume without re-litigating.
---

# writing-handoff

Use this skill whenever a conversation reaches a natural close-point and the next session would benefit from a structured resume prompt. Invoked automatically on trigger phrases, and manually via `/handoff`.

## Goal

Prevent the next session from re-deriving context you already have, and prevent it from drifting into rabbit holes you already ruled out.

## When to invoke without being asked

- User says "wrap up", "done for now", "handoff", "pick this up later", "that's enough for today".
- A major decision just closed and work is pausing (user posted something externally and is waiting for feedback, topic concluded with no immediate next action, blocker requires external input).
- A plan exists in `~/.claude/plans/` with a deliberate wait/gate condition.

Do **not** invoke after every turn. Only at genuine close-points. If unsure, don't.

## Checklist

Before writing the handoff, confirm each of these is captured:

1. **First action** — One concrete sentence. A specific file to read, command to run, or page to check. Not "review things", not "pick up where we left off".
2. **Gating condition** — What must be true before executing the first action. External responses awaited? Approvals needed? Environment state?
3. **Pointers, not content** — Paths to plan files (`~/.claude/plans/...`), memory entries, and critical code. Do not duplicate what already lives in `MEMORY.md` or plan files — link to them.
4. **State that would otherwise be lost** — Decisions made, options considered and rejected, and the *why* behind each. Emotional or strategic context that won't survive in a diff.
5. **What NOT to do** — Rabbit holes to avoid, re-litigation to prevent, questions that were already answered.

## File location

`~/.claude/plans/handoff-YYYY-MM-DD-<topic>.md`

- One file per topic close.
- If the same topic reopens and closes again, overwrite.
- Keep filenames filesystem-safe (no spaces, no special chars in the topic slug).

## Output format

```markdown
# Handoff — <topic> (YYYY-MM-DD)

## First action next session
<one concrete sentence>

## Gating condition
<what must be true before executing>

## Pointers
- Plan: `~/.claude/plans/...`
- Memory: `~/.claude/projects/<project>/memory/...`
- Code: `<path>:<function>`

## Context not preserved elsewhere
<decisions, rejected options with rationale, strategic notes>

## Do not
- <rabbit hole #1>
- <re-litigation pattern #2>
```

## After writing

- State the file path and a one-line summary of what was captured.
- Keep prose terse. Long narrative in handoffs is drift-bait.
- Do not commit the handoff to git unless asked — `~/.claude/plans/` is personal workspace, not repo-tracked.
