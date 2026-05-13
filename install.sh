#!/usr/bin/env bash
# install.sh — Install Claude configuration into ~/.claude/
# Backs up any existing files before overwriting.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$CLAUDE_DIR"

# Back up existing files we're about to overwrite
backed_up=0
for f in "CLAUDE.md" "templates/wiki"; do
  if [ -e "$CLAUDE_DIR/$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp -r "$CLAUDE_DIR/$f" "$BACKUP_DIR/$f"
    backed_up=1
  fi
done

if [ "$backed_up" -eq 1 ]; then
  echo "Backed up existing files to $BACKUP_DIR"
fi

# Install
cp "$REPO_ROOT/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "Installed CLAUDE.md"

mkdir -p "$CLAUDE_DIR/templates"
cp -r "$REPO_ROOT/templates/"* "$CLAUDE_DIR/templates/"
echo "Installed templates/"

echo ""
echo "Done. Open a new Claude Code session and run /memory to verify ~/.claude/CLAUDE.md is loaded as User memory."
