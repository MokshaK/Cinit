# Cinit — Claude Code Configuration

Personal Claude Code configuration: global behavior rules, project-wiki schema, lessons-learned system, test-runner hook, and platform-specific settings. Versioned so it can be synced across machines.

## What's here

```
.
├── CLAUDE.md                              # Global rules loaded in every session
├── install.ps1                            # Windows installer
├── install.sh                             # macOS / Linux / WSL installer
├── settings/
│   ├── settings.windows.json              # Hooks + audio for Windows
│   ├── settings.macos.json                # Hooks + audio for macOS
│   └── settings.linux.json                # Hooks + audio for Linux
├── hooks/
│   ├── run_tests.py                       # PostToolUse hook: runs project tests after every edit
│   └── README.md                          # Hook configuration reference
├── refs/
│   └── python-uv.md                       # uv install + migration recipes (referenced from CLAUDE.md)
├── skills/
│   ├── lessons-review/SKILL.md            # /lessons-review — end-of-project lessons promotion ritual
│   └── sync-cinit/SKILL.md                # /sync-cinit — pull latest Cinit and re-run installer
├── templates/
│   └── wiki/
│       ├── PROJECT_WIKI_SCHEMA.md         # LLM Wiki spec (Karpathy-inspired) — 5 sections + 2 appendices
│       ├── index.md                       # Wiki entry-point skeleton
│       ├── log.md                         # Wiki changelog skeleton
│       └── lessons.md                     # Project lessons-learned skeleton
└── README.md                              # This file
```

All of this installs into `~/.claude/`. Claude Code reads `~/.claude/CLAUDE.md` automatically on every session; skills register from `~/.claude/skills/`; hooks fire from `~/.claude/settings.json`.

## Install on a new machine

Clone the repo, then run the installer for your platform.

**Windows (PowerShell):**
```powershell
git clone https://github.com/MokshaK/Cinit.git ~/projects/Cinit
~/projects/Cinit/install.ps1
```

**macOS / Linux / WSL:**
```bash
git clone https://github.com/MokshaK/Cinit.git ~/projects/Cinit
~/projects/Cinit/install.sh
```

The installer:
- Detects the platform and picks the matching `settings/settings.<platform>.json`.
- Copies `CLAUDE.md`, `templates/`, `hooks/`, `refs/`, `skills/` into `~/.claude/`.
- Backs up overwritten files to `~/.claude/backups/install-<timestamp>/` before replacing them.
- Skips `settings.local.json` entirely — that file is per-machine and never owned by Cinit.

Pass `--dry-run` to either script to preview without writing anything.

**After installing for the first time, fully restart Claude Code** so the new top-level `~/.claude/skills/` directory gets watched. Subsequent installs don't need a restart.

## Update workflow

### From a running Claude Code session
```
/sync-cinit
```
This pulls latest from origin and re-runs the installer. Works for both first-time setup (clones if absent) and ongoing refresh.

### Manually
```bash
cd ~/projects/Cinit && git pull && ./install.sh    # or install.ps1
```

### When you change a rule
1. Edit the file in this repo (not the copy in `~/.claude/`).
2. Run the installer to sync to `~/.claude/`.
3. Commit and push so the change is captured for other machines.

This keeps the repo as the source of truth. Editing `~/.claude/` directly works but creates drift between machines.

## Architecture

Three layers, all loaded together (not replacing each other):

```
~/.claude/CLAUDE.md              ← global behavior, loaded every session
        +
<repo>/CLAUDE.md                 ← project-specific overlay (created by wiki bootstrap)
        +
<repo>/<subdir>/CLAUDE.md        ← nested overrides (rare; used in monorepos)
```

More-specific levels win on conflict; all levels apply additively otherwise.

## What's in `CLAUDE.md`

1. **Coding behavior** — state assumptions, minimum code, surgical edits, verifiable success criteria.
2. **Testing: verify before claiming done** — green-at-completion as hard rule, test-first as default for new behavior, anti-tautology guard, hook integration.
3. **Wiki-First Documentation Pattern** — on first turn in a new repo, detect bootstrap state and scaffold from `templates/wiki/` if the project meets the criteria.
4. **Python tooling** — `uv` as the default with explicit carve-outs (Conda for ML, Poetry for existing, stdlib for throwaways).
5. **Verify the premise before solving** — cheapest-diagnostic-first when something is reported broken.
6. **Commit cadence** — checkpoint commits as a recovery tool, not bookkeeping.
7. **Editing layer hygiene** — three rules about operating at the right abstraction layer (no multi-line pastes into Windows shells, treat bundled artifacts as read-only, beware manual multi-paste deploys).

Reference material extracted from `CLAUDE.md` lives in `hooks/README.md` (hook configuration detail) and `refs/python-uv.md` (uv install + migration). These are read on demand, not preemptively.

## What's in `templates/wiki/`

The Karpathy-inspired "LLM Wiki" pattern, codified. When a substantial project gets bootstrapped, these files are copied to `<repo-root>/` and then organized into `docs/wiki/` by the schema's own Bootstrap Protocol (`PROJECT_WIKI_SCHEMA.md` §0).

- `PROJECT_WIKI_SCHEMA.md` — the spec. 6 sections: Bootstrap, Core Philosophy, Directory Structure, Ingest Protocol, Context Optimization, Linting Operation, Lessons Review Ritual. Plus two appendices (page templates + First Ingest quickstart).
- `index.md` — wiki entry-point skeleton.
- `log.md` — append-only changelog skeleton.
- `lessons.md` — project lessons-learned skeleton with the capture template (incident, cost, root cause, local rule, `Generalizable?` field, candidate global rule).

## What's in `skills/`

- **`/lessons-review`** — end-of-project ritual that reads `docs/wiki/lessons.md`, classifies entries by `Generalizable?`, and proposes which should promote to user memory (Tier 2) or global CLAUDE.md rules (Tier 3). Never auto-edits global rules — proposes; user confirms each promotion.
- **`/sync-cinit`** — pulls latest Cinit and re-runs the installer. Handles new-machine bootstrap and ongoing sync.

## Verifying it loaded

Open a Claude Code session and run `/memory`. You should see `~/.claude/CLAUDE.md` listed under **User memory**. Type `/` and look for `lessons-review` and `sync-cinit` in the skill list. If anything's missing, re-run the installer and fully restart Claude Code (new top-level skill directories need a restart to be watched).
