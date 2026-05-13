# Global Coding Conventions

These rules apply to every project I work on, regardless of language, framework, or scope. They layer below any project-level `CLAUDE.md`; project rules win on conflict.

---

## Coding behavior

These rules bias toward caution and minimalism over speed. For trivial tasks, use judgment.

### State assumptions; don't pick silently

If a request has multiple valid interpretations, present them rather than choosing one and hoping. If something is unclear, name what's confusing and ask before coding. Confident-sounding output that papers over uncertainty is the leading cause of *"this isn't what I wanted"* rework. Surface tradeoffs and push back when a simpler approach exists — silent compliance with a flawed plan is not helpfulness.

### Minimum code that solves the problem

No speculative features, configurability, or abstractions beyond what was asked. No error handling for impossible scenarios. If a 200-line solution could be 50, write the 50. The reviewer test: *"Would a competent senior engineer call this overcomplicated?"* If yes, cut.

### Surgical edits

Touch only what's needed to complete the task:
- Don't refactor, reformat, or "improve" adjacent code that wasn't part of the request.
- Match the existing style and patterns, even when you'd prefer otherwise.
- Clean up orphans (unused imports, dead variables) **only when they result from your changes**. Pre-existing dead code stays unless explicitly asked.
- If you spot something genuinely broken nearby, mention it — don't fix it silently.

The test: every changed line should trace back to the user's request.

### Verifiable success criteria

For non-trivial tasks, define success in terms that can actually be checked:
- *"Add validation"* → write tests for invalid inputs, make them pass.
- *"Fix bug X"* → write a failing test that reproduces X, then make it pass.
- *"Refactor Y"* → confirm tests pass before and after.

For multi-step tasks, post a brief plan with one verification step per phase before starting. Strong criteria let you iterate independently; weak criteria ("make it work") force the user back to clarify.

---

## Wiki-First Documentation Pattern

Every non-trivial project I work on uses the LLM Wiki pattern. The authoritative spec is:

```
~/.claude/templates/wiki/PROJECT_WIKI_SCHEMA.md
```

Do **not** inline the schema into your context unless you actually need to consult it. It is 460+ lines; read it on demand, not preemptively.

### On the first turn of any coding session in a repository:

1. **Detect.** Check whether `PROJECT_WIKI_SCHEMA.md` exists at the repo root.

2. **If it exists:** Read it and run the schema's own Bootstrap Protocol (§0). That protocol is idempotent — safe to run on already-bootstrapped repos.

3. **If it does NOT exist** AND the user is doing real engineering work (not a one-off question, not a script-shaped task):
   a. **Apply the size guard.** Count source files and rough lines. If the repo is < ~500 lines, a single-file script, or an obvious throwaway prototype, **do not** scaffold the wiki silently. Mention it once, ask the user, and skip if they decline.
   b. **If they confirm (or the repo is clearly substantial):** copy the three template files from `~/.claude/templates/wiki/` to the repo root:
      - `PROJECT_WIKI_SCHEMA.md`
      - `index.md`
      - `log.md`
   c. Then run the Bootstrap Protocol from §0 of the freshly-copied schema. The protocol will move `index.md` and `log.md` into `docs/wiki/`, create the subdirectory structure, and generate the `CLAUDE.md` bridge file at the repo root.

4. **After bootstrap:** the project-local `CLAUDE.md` (created by the bootstrap) becomes authoritative for that repo. Follow its Wiki-First Workflow.

5. **Do NOT run the First Ingest (Appendix B of the schema) without asking.** It is substantial work for a large existing codebase. Offer it; let the user choose timing.

### Guard against ceremony creep

The wiki pattern pays off on projects with multiple modules, multiple developers, or multi-month lifespans. It is **overhead** on small projects. When in doubt, ask before scaffolding. A half-built wiki is worse than no wiki because it lies by omission.

---

## Python: dependency isolation and tooling

**Use `uv` for all Python projects.** uv replaces `pip`, `venv`, `pyenv`, and most of Poetry in one Rust-based binary, 10–100× faster than the alternatives. As of 2026 it is the default in the Python ecosystem; do not reach for `pip install` or `python -m venv` without an explicit reason from the list below.

### Default workflow

- `uv init <project>` — scaffold a new project (creates `pyproject.toml`, `.python-version`)
- `uv add <package>` — add a runtime dependency
- `uv add --dev <package>` — add a dev-only dependency
- `uv run <command>` — execute inside the managed env, no manual activation needed
- `uv sync` — install from `uv.lock` (CI, fresh clones, after pulling)
- `uv python install <version>` — install a specific Python version

Commit `uv.lock`. Gitignore `.venv/`.

### When NOT to use uv

The only acceptable reasons to skip uv:

1. **Existing Poetry project.** Don't migrate mid-project without a clear reason. Poetry is still actively maintained.
2. **Scientific / ML stack with heavy binary dependencies** — PyTorch+CUDA, OpenCV, complex geospatial. Use Conda or Mamba; uv struggles when packages need to compile against system libs.
3. **Single-file throwaway script** with stdlib-only imports. `python foo.py` is fine; don't ceremoniously scaffold a project for a 30-line script.

If you fall back to `pip` + `venv` for any reason **outside** that list, say so explicitly before doing it. Silent regression to legacy tooling is how standards rot.

### If uv isn't installed on the user's machine

Surface the install command — don't run it silently:

- **Windows:** `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"` or `winget install --id=astral-sh.uv -e`
- **macOS / Linux:** `curl -LsSf https://astral.sh/uv/install.sh | sh`

### Migration from legacy projects

`requirements.txt`-based projects can be migrated to uv trivially with `uv pip compile requirements.in -o requirements.txt` in pip-compatibility mode, or fully ported with `uv init` + re-adding dependencies. Ask the user before migrating.

---

## Other global preferences

(Add further language-specific or workflow rules below. Keep this file tight — every line is loaded into every session.)
