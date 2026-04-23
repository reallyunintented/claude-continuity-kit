# Additions for ~/.claude/CLAUDE.md

## 1. Shortcut rule

Add this bullet to your `# Working Style` section (or wherever behavior rules live in your CLAUDE.md):

```
- If the user types `verify first` or `source please` (or similar hard-verify phrasing) at the start of a turn, treat it as an override: do not answer from memory, prior context, or assumption. Re-read the authoritative source (filesystem, nearest repo `CLAUDE.md`, or the curated insights doc) before responding. Applies to that turn only.
```

## 2. Auto-Memory Discipline (recommended new section)

The hook and skill backstop these rules. Without them, the ruleset has no teeth; with them, the rules become the default behavior instead of aspirational prose. Paste this as a new section near the top of your CLAUDE.md:

```
# Auto-Memory Discipline
Auto-memory lives at `~/.claude/projects/<project>/memory/` and is notes Claude writes about the user/projects to carry across sessions. Treat it as a stale observation log, not source of truth.
- Before stating any specific claim sourced from memory (project description, file path, feature existence, status), verify against current filesystem or the authoritative source. Memory ages; directories get renamed; projects get deprecated.
- Memory is for disambiguation and calibration only. Architecture, stack, commands, and invariants belong in each repo's own `CLAUDE.md`. Don't duplicate them into memory — the duplicate will drift and become a liability.
- When a curated insights/status doc exists (e.g. `~/Desktop/dev-insights-*.md`), it is authoritative for project state. Resolve "active vs deprecated vs archived" against that doc, not against the existence of a directory on disk.
- If the user corrects the same memory claim twice in one session, the premise itself is wrong — stop refining the framing, re-read the source, and rewrite from what's actually there.
```
