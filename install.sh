#!/usr/bin/env bash
# Install Cinit rule files into ~/.claude/ on macOS / Linux / WSL.
#
# Copies CLAUDE.md, templates/, hooks/, refs/, skills/, and the
# platform-matching settings.json into the user's ~/.claude/ directory.
# Existing files are backed up to ~/.claude/backups/install-<timestamp>/
# before being overwritten. Re-running is idempotent and safe.
#
# Does NOT touch settings.local.json — that file is per-machine and
# not owned by Cinit.
#
# Run from anywhere; the script uses its own location to find source files.

set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="${CLAUDE_DIR}/backups/install-${TIMESTAMP}"

# Detect platform
case "$(uname -s)" in
    Darwin)         PLATFORM=macos  ;;
    Linux)          PLATFORM=linux  ;;
    MINGW*|MSYS*|CYGWIN*)
        echo "Detected Windows shell environment — use install.ps1 instead." >&2
        exit 1
        ;;
    *)
        echo "Unknown platform: $(uname -s). Defaulting to linux variant." >&2
        PLATFORM=linux
        ;;
esac

step()  { printf "  \033[36m%s\033[0m\n" "$1"; }
ok()    { printf "  \033[32m%s\033[0m\n" "$1"; }
warn()  { printf "  \033[33m%s\033[0m\n" "$1"; }

printf "\nCinit install (%s)\n" "$PLATFORM"
echo "  Source: $SCRIPT_DIR"
echo "  Target: $CLAUDE_DIR"
[[ $DRY_RUN -eq 1 ]] && warn "DRY RUN — no files will be written."
echo

# Ensure target directory exists
if [[ ! -d "$CLAUDE_DIR" ]]; then
    step "Creating $CLAUDE_DIR"
    [[ $DRY_RUN -eq 0 ]] && mkdir -p "$CLAUDE_DIR"
fi

# Items to install: <source-relative> <target-relative> <kind:file|dir>
ITEMS=(
    "CLAUDE.md|CLAUDE.md|file"
    "templates|templates|dir"
    "hooks|hooks|dir"
    "refs|refs|dir"
    "skills|skills|dir"
    "settings/settings.${PLATFORM}.json|settings.json|file"
)

BACKED_UP_COUNT=0

for item in "${ITEMS[@]}"; do
    IFS='|' read -r SRC DST KIND <<< "$item"
    SRC_PATH="${SCRIPT_DIR}/${SRC}"
    DST_PATH="${CLAUDE_DIR}/${DST}"

    if [[ ! -e "$SRC_PATH" ]]; then
        warn "Source missing, skipping: $SRC"
        continue
    fi

    # Back up existing target before overwriting
    if [[ -e "$DST_PATH" ]]; then
        BACKUP_PATH="${BACKUP_ROOT}/${DST}"
        step "Backing up existing $DST -> $BACKUP_PATH"
        if [[ $DRY_RUN -eq 0 ]]; then
            mkdir -p "$(dirname "$BACKUP_PATH")"
            if [[ "$KIND" == "dir" ]]; then
                cp -R "$DST_PATH" "$BACKUP_PATH"
            else
                cp "$DST_PATH" "$BACKUP_PATH"
            fi
        fi
        BACKED_UP_COUNT=$((BACKED_UP_COUNT + 1))
    fi

    step "Installing $SRC -> $DST"
    if [[ $DRY_RUN -eq 0 ]]; then
        if [[ "$KIND" == "dir" ]]; then
            # Remove target first so deletions in source propagate
            [[ -e "$DST_PATH" ]] && rm -rf "$DST_PATH"
            cp -R "$SRC_PATH" "$DST_PATH"
        else
            mkdir -p "$(dirname "$DST_PATH")"
            cp "$SRC_PATH" "$DST_PATH"
        fi
    fi
done

# Make hooks/run_tests.py executable
if [[ $DRY_RUN -eq 0 ]] && [[ -f "${CLAUDE_DIR}/hooks/run_tests.py" ]]; then
    chmod +x "${CLAUDE_DIR}/hooks/run_tests.py"
fi

echo
ok "Install complete."
if [[ $BACKED_UP_COUNT -gt 0 ]]; then
    printf "  \033[90mBacked up %d existing items to:\033[0m\n" "$BACKED_UP_COUNT"
    printf "    \033[90m%s\033[0m\n" "$BACKUP_ROOT"
fi
printf "  \033[90mNext: restart Claude Code so new top-level skills directories are watched.\033[0m\n"
echo
