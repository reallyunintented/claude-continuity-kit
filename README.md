# claude-continuity-kit

Small levers for Claude Code **session continuity** — two independent halves, each a set of mutually reinforcing skills, hooks, and rules:

- **Memory half** — stops Claude's auto-memory from drifting into stale, wordy, or unverified claims.
- **Handoff half** — makes sessions close cleanly so the next one resumes without re-deriving context.

Non-blocking, advisory, frictionless. Each lever is independent. Install both halves, one half, or any subset.

> Previously this repo was `claude-memory-kit`. It grew to cover handoffs too and was renamed. GitHub redirects the old URL.

## The problem

Sessions don't carry state the way coworkers do. Two failure modes in particular:

**Memory drift.** Claude Code's auto-memory (files under `~/.claude/projects/<project>/memory/`) is there so future sessions aren't cold-starting. The failure mode is drift — descriptions go stale, memory duplicates what already lives in a repo's own `CLAUDE.md` and falls out of sync, deprecated projects get re-added as active, Claude carries forward an old memory claim for several turns without re-checking. Prose rules in `CLAUDE.md` alone don't catch this.

**Handoff gaps.** A session ends for reasons that aren't always "we finished the work" — a decision was made and you're now waiting on external feedback, you hit a blocker, the context window filled up. When the next session opens, Claude has no idea. It may re-litigate decisions you already made, re-brainstorm options you already rejected, or execute a plan that was explicitly gated on feedback you're still waiting for.

Both are *continuity* problems — state not surviving the gap between sessions. This kit adds machine-checkable backstops so the gap stays small.

## What's in the kit

### Memory half

1. **Shortcut rule** (`claude-md.snippet.md`, §1-2) — `verify first` / `source please` at the start of a turn becomes a documented override: Claude is instructed to re-read the authoritative source before answering. User-side kill-switch.
2. **Skill** (`skills/writing-memory/SKILL.md`) — structured checklist Claude walks before writing or asserting from memory.
3. **Hook — `hooks/memory-guard.sh`** (PreToolUse) — fires on any `Write`/`Edit` to `~/.claude/projects/*/memory/`, emits the checklist to stderr.
4. **Hook — `hooks/session-reminder.sh`** (SessionStart) — front-loads memory discipline at the start of every session.
5. **Optional — `/verify` slash command** (`commands/verify.md`) — shorter alternative to typing `verify first`.

### Handoff half

6. **Behavior rule** (`claude-md.snippet.md`, §3) — defines *when* Claude should write a handoff without being asked (trigger phrases, close-points, wait-states) and *what* the handoff must contain.
7. **Skill** (`skills/writing-handoff/SKILL.md`) — structured format for the handoff file itself so it's execution-oriented and resumes cleanly.
8. **Hook — `hooks/handoff-surface.sh`** (SessionStart) — finds the most recent `~/.claude/plans/handoff-*.md` and, if fresh (< 14 days by default), emits it as additional context at the start of the next session.
9. **Optional — `/handoff` slash command** (`commands/handoff.md`) — manual trigger for writing a handoff at an unambiguous close-point.

Each lever is independent. Using both halves together gives defence in depth: hooks are the ratchet (harness-enforced), skills are the structured reasoning, rules and slash commands are your manual overrides.

## Install

### Prerequisites

- [Claude Code](https://claude.com/claude-code) installed.
- `jq` (used by the memory-guard hook). Debian/Ubuntu: `sudo apt install jq`. macOS: `brew install jq`.
- `bash` 4+.

### Option A — one-shot script

```bash
git clone https://github.com/reallyunintented/claude-continuity-kit.git
cd claude-continuity-kit
./install.sh
```

The script copies skills, hooks, and slash commands into `~/.claude/`, then **prints** the `settings.json` and `CLAUDE.md` snippets for you to merge manually. It does not auto-edit those files because they're personal and likely contain other things.

### Option B — manual, full install

```bash
mkdir -p ~/.claude/skills/writing-memory ~/.claude/skills/writing-handoff \
         ~/.claude/hooks ~/.claude/commands ~/.claude/plans
cp skills/writing-memory/SKILL.md  ~/.claude/skills/writing-memory/
cp skills/writing-handoff/SKILL.md ~/.claude/skills/writing-handoff/
cp hooks/memory-guard.sh hooks/session-reminder.sh hooks/handoff-surface.sh ~/.claude/hooks/
cp commands/verify.md commands/handoff.md ~/.claude/commands/
chmod +x ~/.claude/hooks/memory-guard.sh ~/.claude/hooks/session-reminder.sh ~/.claude/hooks/handoff-surface.sh
```

### Option C — manual, half install

Install only memory or only handoff — each half's files are independent.

**Memory only:**
```bash
cp skills/writing-memory/SKILL.md ~/.claude/skills/writing-memory/
cp hooks/memory-guard.sh hooks/session-reminder.sh ~/.claude/hooks/
cp commands/verify.md ~/.claude/commands/
chmod +x ~/.claude/hooks/memory-guard.sh ~/.claude/hooks/session-reminder.sh
```

**Handoff only:**
```bash
cp skills/writing-handoff/SKILL.md ~/.claude/skills/writing-handoff/
cp hooks/handoff-surface.sh ~/.claude/hooks/
cp commands/handoff.md ~/.claude/commands/
chmod +x ~/.claude/hooks/handoff-surface.sh
```

Then in all cases:

1. Merge the relevant pieces of `settings.snippet.json` into `~/.claude/settings.json`. If your settings file already has a `hooks` key, merge the entries into the existing arrays. Replace `$HOME` with your actual home path if your Claude Code version doesn't expand environment variables in hook commands.
2. Append the relevant sections from `claude-md.snippet.md` to `~/.claude/CLAUDE.md`.

## Verify

Run the included test:

```bash
./test.sh
```

Ten scenarios should pass: memory hook emits on auto-memory paths and stays silent otherwise, doesn't crash on malformed JSON or empty input, session-reminder emits at SessionStart, handoff-surface surfaces fresh handoffs and stays silent for missing/empty/stale/irrelevant conditions.

End-to-end in a Claude Code session:

- Both new skills should appear in the session's available skills list (`writing-memory`, `writing-handoff`).
- Start a session: the `[memory-kit]` and `[handoff-kit]` banners should appear as SessionStart context (handoff banner only if a fresh handoff file exists).
- Ask Claude to update anything under `~/.claude/projects/<project>/memory/`: the `[memory-guard]` checklist should appear before the write.
- Type `verify first` at the start of a turn: Claude should re-read the relevant source file instead of answering from memory.
- Type `/handoff` at a close-point: Claude should write a handoff file to `~/.claude/plans/handoff-YYYY-MM-DD-<topic>.md`.
- Start a new session: the handoff should be surfaced as additional context.

## Uninstall

Full:
```bash
rm -rf ~/.claude/skills/writing-memory ~/.claude/skills/writing-handoff
rm -f  ~/.claude/hooks/memory-guard.sh ~/.claude/hooks/session-reminder.sh ~/.claude/hooks/handoff-surface.sh
rm -f  ~/.claude/commands/verify.md ~/.claude/commands/handoff.md
```

Then remove the corresponding entries from `~/.claude/settings.json` and the corresponding sections from `~/.claude/CLAUDE.md`. Each lever is independent — remove any subset without breaking the rest.

## Notes & caveats

- **It's a ratchet, not a solve.** Even with everything installed, Claude can still drift. The point is to make the default behavior better and make drift visible earlier, not to prevent every failure. The hook stderr reminders are only useful if someone (you or Claude) notices them.
- **Hook schema assumption.** `memory-guard.sh` reads `tool_input.file_path` from the JSON Claude Code sends to `PreToolUse` hooks. If a future Claude Code version changes that schema, the hook silently stops matching — no false positives, just quiet. If the kit starts feeling less effective after a Claude Code update, run `./test.sh` first, then inspect what Claude Code actually sends to hooks.
- **Handoff judgment is imperfect.** The hook surfaces handoffs when they exist; the skill structures them well when Claude decides to write one. But deciding to write one in the first place is still Claude's judgment call. Use `/handoff` or an explicit trigger phrase ("wrap up") when you want to be sure.
- **Skill visibility.** Skills are listed in the "available skills" system-reminder. If you install mid-session and a skill doesn't appear, restart Claude Code.
- **Privacy.** The hooks read only minimal fields (the memory-guard reads `file_path`, handoff-surface reads filenames and mtimes in your own `~/.claude/plans/`). Nothing is logged to disk, uploaded, or sent over the network.
- **Non-blocking by design.** If you want blocking behavior (reject the tool call unless verification is announced), change `exit 0` to `exit 2` in `memory-guard.sh`. That interrupts Claude mid-reasoning and is less friendly; start non-blocking and only escalate if drift persists.
- **Co-existing hooks.** If you already have `PreToolUse` / `SessionStart` hooks configured, merge the new entries into your existing arrays rather than replacing them — Claude Code runs all matching hooks in order.
- **Hook overhead.** Each hook is small (jq call for memory-guard, find call for handoff-surface, bash printf for session-reminder). Budget single-digit milliseconds per invocation.
- **Stale handoffs get suppressed.** `handoff-surface.sh` hides handoffs older than `HANDOFF_MAX_AGE_DAYS` (default 14). Override via env var. After a handoff is executed or superseded, delete the file so it doesn't resurface.
- **No cross-machine sync.** `~/.claude/plans/` and `~/.claude/projects/*/memory/` are local directories. If you switch machines mid-project, these don't travel by default. Sync them with your dotfiles repo if you want that.

## How this came to be

The memory half was built during a live debugging session where Claude repeatedly drifted from its own auto-memory discipline — carried forward a stale project description (confused one DeFi project's identity for another's for several turns), duplicated architecture details into memory that already lived in the repo's own `CLAUDE.md`, and added a deprecated project as active because the directory still existed.

The handoff half was built the next day, when a project's foundation was removed by an upstream vendor and the user had to post a public question asking what the project should become. Mid-brainstorm the user noticed the same problem in reverse — "how do we make sure the next session doesn't re-derive all of this when we resume?" — and the kit's second half fell out naturally.

Both halves came out of back-and-forths where Claude's own failure modes were both the subject and the co-author. This kit is as much a record of those conversations as it is a utility. Use it, fork it, make it your own.

## License

MIT. See [LICENSE](LICENSE).
