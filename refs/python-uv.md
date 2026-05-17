# Python tooling: uv install and migration

Background reference. The rule-level guidance ("use uv, here are the carve-outs") lives in `~/.claude/CLAUDE.md` — this file is the install/migration material that was extracted to keep CLAUDE.md lean.

## Installing uv

Surface the install command to the user — don't run it silently.

- **Windows (PowerShell):**
  ```powershell
  powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
  ```
- **Windows (winget):**
  ```powershell
  winget install --id=astral-sh.uv -e
  ```
- **macOS / Linux / WSL:**
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```

After installation, verify with `uv --version`.

## Migration from legacy projects

### From `requirements.txt` (pip-compatibility mode)

For projects that want to keep the `requirements.txt` workflow but use uv for speed:

```bash
uv pip compile requirements.in -o requirements.txt
uv pip sync requirements.txt
```

### From `requirements.txt` to full uv project

For projects that want to fully adopt uv (recommended for active projects):

```bash
uv init --no-readme           # creates pyproject.toml without overwriting existing README
# then re-add each dependency from requirements.txt:
uv add <package>
uv add --dev <dev-package>
```

Drop `requirements.txt` from version control once `uv.lock` is committed.

### From Poetry

uv can read most Poetry `pyproject.toml` files directly. Try `uv sync` first — if it works, just commit `uv.lock` and remove the `[tool.poetry]` sections at your leisure. If it fails, migrate dependency-by-dependency.

### From `setup.py` / `setuptools`

`uv init` followed by re-declaring dependencies is the cleanest path. Modern uv projects use `pyproject.toml` exclusively.

## When migration is risky

- Lock-file-sensitive projects (security-audited, reproducibility-critical): pin Python version with `.python-version`, commit `uv.lock`, verify reproducibility on a clean checkout before declaring done.
- Projects with C-extension dependencies that pip's build path supports but uv's might not: test a fresh `uv sync` in a clean venv before committing.

## Related

- Rule-level guidance: `~/.claude/CLAUDE.md` (Python section)
- Official docs: https://docs.astral.sh/uv/
