# claude-memory-kit

Three small levers to stop Claude Code's auto-memory from drifting into stale, wordy, or unverified claims. Non-blocking, advisory, frictionless.

## The problem

Claude Code's auto-memory (files under `~/.claude/projects/<project>/memory/`) accumulates across sessions so that future Claudes aren't cold-starting every time. That's the value. The failure mode is drift:

- Descriptions go stale (project X gets rewritten but the memory still describes the old version).
- Memory duplicates what already lives in a repo's own `CLAUDE.md` and then falls out of sync.
- Deprecated projects get re-added as active because the directory still exists on disk.
- Claude carries forward an old memory claim for several turns without checking whether it's still true.

Prose rules in `CLAUDE.md` alone don't catch this. They're instructions, not enforcement, and Claude routinely drifts from its own documented rules.

## What's in the kit

Three mutually reinforcing levers:

1. **Shortcut rule** (`claude-md.snippet.md`) — The phrase `verify first` or `source please` at the start of a turn becomes a documented override: Claude is instructed to re-read the authoritative source before answering, not respond from memory or assumption. User-side kill-switch.

2. **Skill** (`skills/writing-memory/SKILL.md`) — A structured checklist Claude is instructed to walk before writing or asserting from memory. Claude Code skills get announced when invoked, which makes the reasoning visible.

3. **Hooks** — Two non-blocking hooks that the harness runs (not Claude), so they fire regardless of whether Claude remembered to invoke the skill:
   - `hooks/memory-guard.sh` — `PreToolUse` hook. Fires on any `Write`/`Edit` whose `file_path` is under `~/.claude/projects/*/memory/`. Emits the checklist to stderr.
   - `hooks/session-reminder.sh` — `SessionStart` hook. Prints a brief discipline reminder when a new session begins, so the rules are present in context from turn one instead of only after the first memory write.

4. **Optional — `/verify` slash command** (`commands/verify.md`) — A shorter variant of the shortcut. Drop into `~/.claude/commands/verify.md` and type `/verify` instead of `verify first` at the start of a turn. Same effect.

Each lever is independent. Using all of them gives defence in depth: the hooks are the ratchet, the skill is the structured reasoning, the shortcut (and `/verify`) is your manual override.

## Install

### Prerequisites

- [Claude Code](https://claude.com/claude-code) installed.
- `jq` (used by the hook). Debian/Ubuntu: `sudo apt install jq`. macOS: `brew install jq`.
- `bash` 4+.

### Option A — one-shot script

```bash
git clone https://github.com/reallyunintented/claude-memory-kit.git
cd claude-memory-kit
./install.sh
```

The script copies the skill and hook into `~/.claude/`, then **prints** the `settings.json` and `CLAUDE.md` snippets for you to merge manually. It does not auto-edit those files because they're personal and likely contain other things.

### Option B — manual

```bash
mkdir -p ~/.claude/skills/writing-memory ~/.claude/hooks
cp skills/writing-memory/SKILL.md ~/.claude/skills/writing-memory/
cp hooks/memory-guard.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/memory-guard.sh
```

Then:

1. Merge `settings.snippet.json` into `~/.claude/settings.json`. If your settings file doesn't already have a `hooks` key, add the full block. If it does, merge the `PreToolUse` entry into the existing array. Replace `$HOME` in the command path with your actual home path if your Claude Code version doesn't expand environment variables in hook commands — absolute paths are safest.
2. Append `claude-md.snippet.md` content to `~/.claude/CLAUDE.md`.

## Verify

Run the included test:

```bash
./test.sh
```

Four scenarios should pass: hook emits a checklist when the path is under auto-memory, stays silent otherwise, doesn't crash on malformed JSON, doesn't crash on empty input.

End-to-end in a Claude Code session:

- The new `writing-memory` skill should appear in the session's available skills list.
- Ask Claude to update anything in `~/.claude/projects/<project>/memory/`. The `[memory-guard]` checklist should appear in the transcript before the write.
- At the start of any turn, type `verify first` — Claude should re-read the relevant source file instead of answering from memory.

## Uninstall

```bash
rm -rf ~/.claude/skills/writing-memory ~/.claude/hooks/memory-guard.sh
```

Remove the `hooks` key from `~/.claude/settings.json` (or remove the `PreToolUse` entry that points to `memory-guard.sh` if you have other hooks). Delete the appended bullet in `~/.claude/CLAUDE.md`. Each lever is independent — removing one doesn't break the others.

## Notes & caveats

- **It's a ratchet, not a solve.** Even with all three levers in place, Claude can still drift from the rules. The point is to make the default behavior better and make drift visible earlier, not to prevent every failure. Read the transcript; the hook's stderr reminder is only useful if you (or Claude) notice it.
- **Hook schema assumption.** The hook reads `tool_input.file_path` from the JSON Claude Code sends to `PreToolUse` hooks. If a future Claude Code version changes that schema, the hook silently stops matching — it emits nothing, no false positives, just quiet. If the kit starts feeling less effective after a Claude Code update, run `./test.sh` first, then inspect what Claude Code actually sends to hooks.
- **Skill visibility.** Skills are listed in the "available skills" system-reminder. If you install mid-session and `writing-memory` doesn't appear, restart Claude Code.
- **Privacy.** The hook reads only the `file_path` field from tool inputs — never file contents, never stdin text, never anything else. Nothing is logged to disk, uploaded, or sent over the network.
- **Non-blocking by design.** If you want blocking behavior (reject the tool call unless verification is announced), change `exit 0` to `exit 2` in `memory-guard.sh` and the stderr output becomes the block reason. That will interrupt Claude mid-reasoning and is less friendly; start non-blocking and only escalate if drift persists.
- **Co-existing hooks.** If you already have `PreToolUse` hooks configured, merge the `Write|Edit` matcher into your existing array rather than replacing it — Claude Code runs all matching hooks in order.
- **Hook overhead.** The matcher fires on every `Write` and `Edit` (not just memory writes), and the script spawns a shell + jq each time. Budget ~5–20 ms per tool call. Imperceptible for interactive use, potentially measurable in batch edit loops.

## How this came to be

This kit was built during a live debugging session where Claude repeatedly drifted from its own auto-memory discipline. It carried forward a stale project description (confused one DeFi project's identity for another's for several turns), duplicated architecture details into memory that already lived in the repo's own `CLAUDE.md`, and added a deprecated project as active because the directory still existed — even after being told otherwise.

The user caught each drift patiently. Claude eventually named the underlying pattern — treating the presence of a file or old memory claim as ground truth instead of cross-checking against the authoritative source — and we co-designed these three levers as a self-correcting ratchet.

None of this would exist without Claude's collaboration. The skill's checklist, the hook's path-matching, the CLAUDE.md rules it backstops — all came out of a back-and-forth where Claude's own failure modes were both the subject and the co-author. This kit is as much a record of that conversation as it is a utility. Use it, fork it, make it your own.

## License

MIT. See [LICENSE](LICENSE).
