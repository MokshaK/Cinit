#!/usr/bin/env python3
"""
Claude Code PostToolUse hook — run project tests after Edit/Write.

Reads the hook payload on stdin, locates the project root, detects the
test runner, and runs it. Exits 2 (with diagnostics on stderr) on
failure so Claude sees the failure and fixes it. Exits 0 otherwise.

Cross-platform: works under cmd, PowerShell, bash, zsh.
Polyglot: detects uv/pip Python, npm/pnpm/yarn JS, cargo, go.

Install location:
  Linux/macOS:  ~/.claude/hooks/run_tests.py
  Windows:      %USERPROFILE%\\.claude\\hooks\\run_tests.py

Wire it into ~/.claude/settings.json — see the accompanying settings.json.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

# Files where an edit should NOT trigger a test run.
SKIP_SUFFIXES = (
    ".md", ".txt", ".rst", ".json", ".toml", ".yaml", ".yml",
    ".lock", ".log", ".gitignore", ".env", ".cfg", ".ini",
)

# Path tokens (case-insensitive) that mark non-source areas.
SKIP_DIR_TOKENS = (
    "/docs/", "\\docs\\",
    "/.claude/", "\\.claude\\",
    "/.git/", "\\.git\\",
    "/node_modules/", "\\node_modules\\",
    "/.venv/", "\\.venv\\",
    "/venv/", "\\venv\\",
    "/dist/", "\\dist\\",
    "/build/", "\\build\\",
    "/target/", "\\target\\",
    "/__pycache__/", "\\__pycache__\\",
)

# Project markers, checked in order. First match decides the runner.
PROJECT_MARKERS = ("pyproject.toml", "package.json", "Cargo.toml", "go.mod")

TIMEOUT_SECONDS = 120


def main() -> int:
    # Read the hook payload. Malformed input → fail open, never block.
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0

    tool_input = payload.get("tool_input") or {}
    file_path_str = tool_input.get("file_path") or tool_input.get("path") or ""
    if not file_path_str:
        return 0

    fp_lower = file_path_str.lower()
    if fp_lower.endswith(SKIP_SUFFIXES):
        return 0
    if any(token in fp_lower for token in SKIP_DIR_TOKENS):
        return 0

    try:
        file_path = Path(file_path_str).resolve()
    except (OSError, RuntimeError):
        return 0

    project_root = find_project_root(file_path)
    if project_root is None:
        return 0  # not in a recognised project

    cmd = detect_test_command(project_root)
    if cmd is None:
        return 0  # project type known but no test runner configured

    try:
        result = subprocess.run(
            cmd,
            cwd=project_root,
            capture_output=True,
            text=True,
            timeout=TIMEOUT_SECONDS,
        )
    except subprocess.TimeoutExpired:
        sys.stderr.write(
            f"⏱  Test run timed out after {TIMEOUT_SECONDS}s.\n"
            f"   Edited: {file_path.name}\n"
            f"   The suite may be too slow to run on every edit. "
            f"Consider pytest-testmon, scoping by path, or moving slow "
            f"tests to a separate marker.\n"
        )
        return 2
    except FileNotFoundError:
        # Test runner not installed. Don't block Claude on missing tooling —
        # surface a note and continue. The user can install it or remove this
        # hook for projects where it doesn't apply.
        sys.stderr.write(
            f"⚠  Test runner not found: {cmd[0]!r}.\n"
            f"   Skipping the test gate for this edit. "
            f"Install the runner or remove this hook.\n"
        )
        return 0

    if result.returncode != 0:
        sys.stderr.write(
            f"❌ Tests failed after editing {file_path.name}\n"
            f"   Command: {' '.join(cmd)}\n"
            f"   Working dir: {project_root}\n"
            f"\n--- stdout ---\n{result.stdout}\n"
            f"--- stderr ---\n{result.stderr}\n"
        )
        return 2

    # Success — stay silent. Noise in stderr ends up in Claude's context.
    return 0


def find_project_root(start: Path) -> Path | None:
    for parent in (start, *start.parents):
        for marker in PROJECT_MARKERS:
            if (parent / marker).exists():
                return parent
    return None


def detect_test_command(root: Path) -> list[str] | None:
    # Python — prefer uv when uv.lock is present, per the global CLAUDE.md.
    if (root / "pyproject.toml").exists():
        if (root / "uv.lock").exists():
            return ["uv", "run", "pytest", "--tb=short", "-q"]
        if (root / "poetry.lock").exists():
            return ["poetry", "run", "pytest", "--tb=short", "-q"]
        return ["pytest", "--tb=short", "-q"]

    # JavaScript / TypeScript — only if a "test" script is defined.
    if (root / "package.json").exists():
        try:
            pkg = json.loads((root / "package.json").read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            return None
        scripts = pkg.get("scripts") or {}
        if "test" not in scripts:
            return None
        if (root / "pnpm-lock.yaml").exists():
            return ["pnpm", "test", "--silent"]
        if (root / "yarn.lock").exists():
            return ["yarn", "test", "--silent"]
        if (root / "bun.lockb").exists() or (root / "bun.lock").exists():
            return ["bun", "test"]
        return ["npm", "test", "--silent"]

    # Rust.
    if (root / "Cargo.toml").exists():
        return ["cargo", "test", "--quiet"]

    # Go.
    if (root / "go.mod").exists():
        return ["go", "test", "./..."]

    return None


if __name__ == "__main__":
    sys.exit(main())
