# Changelog

All notable changes to claude-memory-kit. Format loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Semver-ish: pre-1.0, minor bumps for new features, patches for fixes.

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

[0.2.0]: https://github.com/reallyunintented/claude-memory-kit/releases/tag/v0.2.0
[0.1]: https://github.com/reallyunintented/claude-memory-kit/releases/tag/v0.1
