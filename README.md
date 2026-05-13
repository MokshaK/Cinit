# Claude Configuration

Personal Claude Code configuration: global behavior rules, project-wiki schema, and Python tooling defaults. Versioned so it can be synced across machines.

## What's here

```
.
├── CLAUDE.md                              # Global rules loaded in every session
├── templates/
│   └── wiki/
│       ├── PROJECT_WIKI_SCHEMA.md         # LLM Wiki spec (Karpathy-inspired)
│       ├── index.md                       # Wiki entry-point skeleton
│       └── log.md                         # Wiki changelog skeleton
├── install.ps1                            # Windows installer
├── install.sh                             # macOS / Linux installer
└── README.md                              # This file
```

These files install into `~/.claude/`. Claude Code reads `~/.claude/CLAUDE.md` automatically at the start of every session. The templates in `~/.claude/templates/wiki/` are used by the global CLAUDE.md to scaffold per-project documentation when starting work in a new repository.

## Install on a new machine

Clone the repo, then run the installer for your platform.

The installer copies `CLAUDE.md` and the `templates/` tree into `~/.claude/`, backing up any existing files first.

## Update workflow

When you change a rule:

1. Edit the file in this repo (not the one in `~/.claude/`).
2. Run the installer to sync to `~/.claude/`.
3. Commit and push so the change is captured.

This keeps the repo as the source of truth. Editing `~/.claude/` directly works but creates drift between machines.

## Architecture

Three layers, loaded in this precedence:

```
~/.claude/CLAUDE.md              ← global behavior + workflow orchestration + tooling
        ↓ loads first, every session
<repo>/CLAUDE.md                 ← project-specific (created by wiki bootstrap)
        ↓ references
<repo>/PROJECT_WIKI_SCHEMA.md    ← wiki spec, read on demand
```

Project-level rules win on conflict with global rules.

## What's in `CLAUDE.md`

1. **Coding behavior** — universal rules: state assumptions, minimum code, surgical edits, verifiable success criteria.
2. **Wiki-First Documentation Pattern** — on first turn in a new repo, detect if the wiki is bootstrapped; if not (and the project is substantial), scaffold it from `templates/wiki/`.
3. **Python tooling** — `uv` as the mandatory default; explicit carve-outs for Conda (ML/binary deps), Poetry (existing projects), and stdlib-only scripts.

## Verifying it loaded

Open a Claude Code session and run `/memory` in the chat. You should see `~/.claude/CLAUDE.md` listed under **User memory**. If you don't, the file isn't being read — re-run the installer.
