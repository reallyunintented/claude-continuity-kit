# Additions for ~/.claude/CLAUDE.md

Two halves — the memory half stops stale claims from carrying forward; the handoff half makes sure close-points actually close cleanly. Each is independent; use whichever fits.

---

## Memory half

### 1. Shortcut rule

Add this bullet to your `# Working Style` section (or wherever behavior rules live in your CLAUDE.md):

```
- If the user types `verify first` or `source please` (or similar hard-verify phrasing) at the start of a turn, treat it as an override: do not answer from memory, prior context, or assumption. Re-read the authoritative source (filesystem, nearest repo `CLAUDE.md`, or the curated insights doc) before responding. Applies to that turn only.
```

### 2. Auto-Memory Discipline (recommended new section)

The hook and skill backstop these rules. Without them, the ruleset has no teeth; with them, the rules become the default behavior instead of aspirational prose. Paste this as a new section near the top of your CLAUDE.md:

```
# Auto-Memory Discipline
Auto-memory lives at `~/.claude/projects/<project>/memory/` and is notes Claude writes about the user/projects to carry across sessions. Treat it as a stale observation log, not source of truth.
- Before stating any specific claim sourced from memory (project description, file path, feature existence, status), verify against current filesystem or the authoritative source. Memory ages; directories get renamed; projects get deprecated.
- Memory is for disambiguation and calibration only. Architecture, stack, commands, and invariants belong in each repo's own `CLAUDE.md`. Don't duplicate them into memory — the duplicate will drift and become a liability.
- When a curated insights/status doc exists (e.g. `~/Desktop/dev-insights-*.md`), it is authoritative for project state. Resolve "active vs deprecated vs archived" against that doc, not against the existence of a directory on disk.
- If the user corrects the same memory claim twice in one session, the premise itself is wrong — stop refining the framing, re-read the source, and rewrite from what's actually there.
```

---

## Handoff half

### 3. Handoff Discipline (recommended new section)

The `handoff-surface.sh` hook surfaces pending handoffs at the start of the next session, and the `writing-handoff` skill structures the writing itself. Without the rule, Claude won't consistently recognize close-points. With it, handoffs become the default at topic close instead of aspirational prose. Paste this as a new section (typically near `# Session Protocol`):

```
# Handoff Discipline
When a topic closes or the session enters wait-state, write a handoff to `~/.claude/plans/handoff-YYYY-MM-DD-<topic>.md` so the next session resumes without re-litigating.

**Write a handoff without being asked when:**
- User says "wrap up", "done for now", "handoff", "pick this up later", "that's enough for today" (explicit triggers).
- A major decision just closed and work is pausing (user posted something externally and is now waiting for feedback; topic concluded with no immediate next action; blocker requires external input).
- A plan exists in `~/.claude/plans/` with a deliberate wait/gate condition.

**What the handoff must contain:**
- **First action for next session** — one concrete sentence. Specific file to read or command to run, not "review things".
- **Gating condition** — what must be true before executing (e.g., "wait for Discussion response", "verify env var X is set").
- **Pointers, not content** — paths to plan files, memory entries, and critical code. Don't duplicate what already lives in `MEMORY.md` or plan files — link to them.
- **State that would otherwise be lost** — decisions made, options considered and rejected, emotional/strategic context that won't survive in a diff.
- **What NOT to do** — rabbit holes to avoid, re-litigation to prevent.

**What a handoff is not:**
- A summary of every turn. Only write at genuine close-points.
- A duplicate of MEMORY.md or the plan file. Link, don't repaste.
- A diary. Keep it execution-oriented.

**Location:** `~/.claude/plans/handoff-YYYY-MM-DD-<topic>.md`. One file per topic close; overwrite only if the same topic reopens and closes again.
```
