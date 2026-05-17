---
name: sync-cinit
description: Sync the user's ~/.claude/ directory with the latest Cinit repo. Clones the repo if absent, pulls latest, then runs the platform-appropriate install script. Use when the user explicitly asks to sync cinit, update Claude rules from cinit, pull latest cinit, or bootstrap Claude rules on a new machine.
---

# Sync Cinit

Brings the local `~/.claude/` directory into alignment with the latest Cinit repo. Handles three scenarios:

1. **First-time setup on a new machine** — clones the repo, runs the install script.
2. **Refresh after pushed changes** — pulls latest, runs the install script.
3. **Existing local clone, want to verify alignment** — pulls latest (no-op if already up to date), runs the install script.

## How it works

1. Resolve `${CINIT_DIR}` (default: `~/projects/Cinit`). Use `$1` as override if provided.
2. If the directory doesn't exist:
   - `git clone https://github.com/MokshaK/Cinit.git "${CINIT_DIR}"`
3. If the directory exists:
   - `git -C "${CINIT_DIR}" pull --rebase`
4. Detect platform and run:
   - Windows: `pwsh "${CINIT_DIR}/install.ps1"` (or `powershell` fallback)
   - macOS / Linux / WSL: `bash "${CINIT_DIR}/install.sh"`
5. Report:
   - What got pulled (commit range or "already up to date").
   - The backup directory created by the install script (so the user can diff before/after if they want).
   - A reminder to restart Claude Code if any new top-level skills directories were created.

## Hard rules

- **Never `git push` from this skill.** Sync is one-way: remote → local. Pushes are explicit user-driven actions; see the commit workflow in the user's CLAUDE.md.
- **Never `git reset --hard` or otherwise destroy local changes** in the Cinit clone. If `git pull --rebase` fails due to local edits, surface that to the user — don't paper over it.
- **Never modify `~/.claude/settings.local.json`.** That file is per-machine, never owned by Cinit.
- **Never re-run the install script after a failed pull.** A failed pull means we're out of sync; running install with stale source files would propagate the staleness to `~/.claude/`. Fix the pull first.

## Invocation

```
/sync-cinit                    # uses ~/projects/Cinit
/sync-cinit /some/other/path   # uses that path instead
```

Or plain English: *"sync cinit"*, *"update my Claude rules from cinit"*, *"pull latest cinit and reinstall"*.

## When NOT to invoke

- If the user has uncommitted local changes in the Cinit clone they haven't pushed yet — sync would block on rebase or create a confusing diff. Tell the user to commit/push first.
- During an active in-session edit of a CLAUDE.md or skill file — sync would overwrite their in-progress work. Finish editing and commit before syncing.

## Implementation note

The script logic lives in `install.ps1` and `install.sh` at the Cinit repo root. This skill is a thin wrapper that ensures the repo is fresh before invoking the installer.
