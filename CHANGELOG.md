# Changelog

All notable changes to claude-continuity-kit (previously claude-memory-kit). Format loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Semver-ish: pre-1.0, minor bumps for new features, patches for fixes.

## [0.3.0] — 2026-04-24

### Added
- **Handoff half** — new independent set of levers for session-close discipline:
  - `skills/writing-handoff/SKILL.md` — structured checklist for what a handoff must contain.
  - `hooks/handoff-surface.sh` — `SessionStart` hook that emits the newest `~/.claude/plans/handoff-*.md` (within `HANDOFF_MAX_AGE_DAYS`, default 14) as additional context so pending handoffs survive into the next session.
  - `commands/handoff.md` — `/handoff` slash command for manual invocation at a close-point.
  - `claude-md.snippet.md` now includes a `# Handoff Discipline` section covering trigger phrases, what the handoff must contain, and where it lives.
- Test coverage for `handoff-surface.sh` in `test.sh` (5 new scenarios: fresh surfaces, missing plans dir silent, empty plans dir silent, stale mtime silent, unrelated files ignored).

### Changed
- **Repo renamed** from `claude-memory-kit` to `claude-continuity-kit`. Scope broadened from memory-only to memory + handoff, both framed as continuity problems (state not surviving the gap between sessions). GitHub redirects the old URL.
- `README.md` — full rewrite covering both halves, the continuity framing, install options for full/memory-only/handoff-only, and updated end-to-end verification steps.
- `settings.snippet.json` — adds a second `SessionStart` entry for `handoff-surface.sh` alongside the existing `session-reminder.sh`.
- `install.sh` — installs both halves, creates `~/.claude/plans/`, prints combined merge instructions.
- `.github/workflows/test.yml` — chmod all three hooks before running tests.
- Hook comment headers updated to reference `claude-continuity-kit`.

### Removed
- Nothing functional removed. The `claude-memory-kit` name and URL still redirect via GitHub.

## [0.2.0] — 2026-04-23

### Added
- `SessionStart` hook (`hooks/session-reminder.sh`) — prints a brief memory-discipline reminder when a new Claude Code session begins. Front-loads the rules instead of waiting for the first memory-write event to trigger a reminder mid-action.
- `/verify` slash command (`commands/verify.md`) — a shorter alternative to typing `verify first` at the start of a turn. Drop into `~/.claude/commands/verify.md` to enable per-user.
- `CHANGELOG.md` (this file).
- Test coverage for `session-reminder.sh` in `test.sh` (now 5 scenarios instead of 4).

### Changed
- `settings.snippet.json` now includes a `SessionStart` hook registration alongside the existing `PreToolUse` entry.
- `install.sh` copies both hooks and prints updated merge instructions.
- `README.md` documents the new pieces.

## [0.1] — 2026-04-23

### Added
- Initial release.
- Shortcut rule (`claude-md.snippet.md`) documenting `verify first` / `source please` as a per-turn override in `CLAUDE.md`.
- `writing-memory` skill (`skills/writing-memory/SKILL.md`) with a pre-write verification checklist.
- `memory-guard.sh` — a non-blocking `PreToolUse` hook that fires on `Write`/`Edit` to `~/.claude/projects/*/memory/` paths and emits a checklist reminder to stderr.
- `install.sh` and `test.sh`.
- GitHub Actions CI workflow (`.github/workflows/test.yml`) running the test suite on push and PR.

[0.3.0]: https://github.com/reallyunintented/claude-continuity-kit/releases/tag/v0.3.0
[0.2.0]: https://github.com/reallyunintented/claude-continuity-kit/releases/tag/v0.2.0
[0.1]: https://github.com/reallyunintented/claude-continuity-kit/releases/tag/v0.1
