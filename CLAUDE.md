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

## Testing: verify before claiming done

### Two hard rules (non-negotiable)

1. **No task is complete until its tests are green.** Reading the code and concluding it works is not verification — running the tests is. If the changed area has no tests, write one before claiming done.
2. **Don't accumulate red tests.** A change that breaks an existing test must be fixed or reverted before the next code change. "I'll come back to those" is how test suites die.

### Test-first or test-alongside, whichever yields a clearer interface

Write the test before or alongside the implementation. The point is the verification loop and the interface-design pressure, not the order of typing. Lead with the test when you can — especially for new behavior in production paths, where the test forces you to commit to a contract before implementing.

The interface-design benefit of strict TDD is partially absorbed by the prompt-and-plan step that precedes code generation in AI-assisted work. So don't fetishize the ordering. Do fetishize the verification.

### Anti-tautology guard

A new test **must fail before its implementation lands**. If a freshly-written test passes on a stub, an empty function, or against the wrong assertion, it isn't testing what it claims. Failure-then-pass is the proof that the test was load-bearing.

Specifically watch for:
- Tests that assert tautologies (`assert x == x`, `assert result is not None` on a function that always returns a value).
- Tests that mock the very thing they purport to test.
- Tests that catch their own setup exceptions and pass silently.
- Tests that exercise no code path the implementation actually owns.

If you can delete a single line from the implementation and the test still passes, the test is not covering that line — say so, and fix one or the other.

### When test-first or written-test-at-all genuinely doesn't apply

- **Exploratory spikes.** You're learning the shape of a problem; tests bake in assumptions you don't have yet.
- **Trivial changes.** Renames, formatting, comment fixes, single-line glue.
- **Code that's genuinely hostile to unit testing.** Pure UI rendering, database migrations, deployment scripts, generated code. Cover these with integration or smoke tests where feasible; do not fabricate a unit test that asserts nothing meaningful.
- **Throwaway scripts.** Same threshold as the wiki size guard and the uv single-script exception below.

When skipping, **say so explicitly.** Silent regression to "no tests" is how coverage rots.

### Discovery on first turn

In a new repo, locate the test command before writing any code. Check, in order:

- `pyproject.toml` (`[tool.pytest]`, `[tool.poetry.scripts]`)
- `package.json` `scripts.test`
- `Cargo.toml`
- `Makefile` `test:` / `check:` targets
- `.github/workflows/*.yml` for what CI actually runs

If none reveal a runner, **ask** — don't guess `pytest` or `npm test` and hope.

### Verification is wired up — respect it

A global hook at `~/.claude/hooks/run_tests.py` runs the project's test suite after every `Edit` or `Write` and surfaces failures on stderr with exit code `2`. Runner detection (uv/npm/cargo/go), project-marker walks, and configuration options live in [`~/.claude/hooks/README.md`](.claude/hooks/README.md) — read that when configuring the hook; otherwise treat it as background infrastructure.

When the hook surfaces a failure: **fix the code, not the test.** Don't assume flakiness without evidence. Don't silence the hook (don't edit `run_tests.py`, don't disable `PostToolUse`, don't reach for `--ignore` flags to make red turn green). If the hook is genuinely misbehaving, surface that and propose a project-local override — don't fix it at the global level mid-task.

Before declaring a task done, **run the full project test suite once more**. The per-edit hook may have run a scoped subset or been disabled in a project override. The agent runs the full suite; not a manual step pushed to the user.

Per-project overrides go in the project's `.claude/settings.json`, **never** the global file. If the hook isn't installed on this machine, surface that once at session start: *"test enforcement is rule-based rather than structural — I'll run tests after each change but it's on me to remember."* Then proceed under the rules above.

### Wiki integration

When the wiki pattern is active:

- Every `modules/*.md` page's `Tests:` evidence anchor must point at the actual test file(s) for that module. If it doesn't, that's a DRIFT lint finding.
- A code change that leaves tests red is **not** a complete ingest. Get tests green first, then log.
- Adding tests for previously untested code is itself an ingest event — record it in `log.md`.

---

## Wiki-First Documentation Pattern

The full spec lives at `~/.claude/templates/wiki/PROJECT_WIKI_SCHEMA.md` (~460 lines). **Don't read it preemptively.** The decision logic below is enough for first-turn bootstrap; only open the full schema if you're actively performing an ingest, lint, or First Ingest.

### When the wiki pattern applies

The pattern earns its keep on projects that meet **at least one** of:

- More than one person will read or edit the code (now or imminently).
- Lifespan expected to exceed ~3 months of active development.
- Multiple modules / packages with non-trivial interactions between them.

It is **overhead, not asset,** on:

- Solo prototypes whose shape is still being discovered.
- Single-file scripts, glue code, or one-off automations.
- Throwaway demos and learning projects.

LOC is a weak proxy for any of this. Prefer the lifespan / team / module-count test. When in doubt, ask once and don't scaffold silently.

### First-turn bootstrap (the short version)

1. **Check** whether `docs/wiki/index.md` exists in the repo. If yes → wiki is bootstrapped, follow the project-local `CLAUDE.md` and move on.

2. **If no, and the project meets the "when it applies" criteria above:**
   - Copy `PROJECT_WIKI_SCHEMA.md`, `index.md`, `log.md`, and `lessons.md` from `~/.claude/templates/wiki/` to the repo root.
   - Run §0 (Bootstrap Protocol) from the freshly-copied schema — that's the only time you need to read the schema. The protocol moves `index.md` / `log.md` / `lessons.md` into `docs/wiki/`, creates the subdirectory structure, and generates the `CLAUDE.md` bridge file.

3. **If no, and the project does not meet the criteria,** don't scaffold. Don't mention the wiki unless the user brings it up — silent unsolicited offers are themselves noise.

4. **Do NOT run the First Ingest (Appendix B of the schema) without asking.** It is substantial work; offer it explicitly and let the user choose timing.

A half-built wiki is worse than no wiki, because it lies by omission. If you bootstrap, plan to do at least three modules + an architecture overview within the next two sessions, or don't bootstrap.

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

### Installation and migration

If uv isn't installed, or you're migrating from `requirements.txt` / Poetry / setuptools, see [`~/.claude/refs/python-uv.md`](.claude/refs/python-uv.md) for platform-specific install one-liners and migration recipes. Surface the install command to the user — don't run it silently. Ask before migrating an existing project.

---

## Verify the premise before solving

When a user reports something is broken — or when *I* form an internal hypothesis that something is broken — the first move is **not** to plan a recovery, write a retrospective, or start refactoring. The first move is to run the cheapest possible diagnostic that would confirm the breakage actually exists.

Half of perceived breakage is one of:
- **Misremembered context** — the user remembers a state that never quite existed.
- **Runtime state needing a refresh** — extension reload, browser tab reload, server restart, cache purge.
- **A documented loading condition mistaken for a failure** — `isReady: false` because an interceptor was installed *after* the request fired, an empty-state UI mistaken for a render failure.

The frame walked in with — *"the last refactor broke everything,"* *"this used to work"* — is hypothesis, not fact. Cheap tests turn hypothesis into fact.

**How to apply:**

1. Before accepting a "broken" framing, ask: *"What is the cheapest test that would confirm this is actually broken?"* If it takes under two minutes, run it before doing anything else.
2. Check: `git diff` against a claimed-good reference, runtime version stamps, the relevant docs/runbook.

Recovery work that solves a non-existent problem is the most expensive kind of effort — it wastes the time spent *and* adds entropy (rule changes, memory edits, restructures) that future sessions live with. If the user is confident the system is broken but cheap tests come back green, push back on the framing — kindly but firmly — rather than help debug a phantom. The hardest part: the person reporting the breakage is often the unreliable narrator, and that includes me.

---

## Commit cadence: checkpoint, don't accumulate

Frequent commits are a *recovery tool*, not bookkeeping ceremony. The cadence is not "commit constantly" — it is:

- **Before any invasive refactor**, commit the current working state, even if the message is `wip: pre-refactor checkpoint`. That commit is your rollback target.
- **After any meaningful change that has been verified to work**, commit it. "Verified" means tests pass or the smoke check passed — not "the code reads correctly to me."
- **Use branches for risky attempts.** A failed refactor on its own branch is `git switch main && git branch -D foo` — one second. The same failed refactor mixed into your working tree is hours of untangling.

When acting as an agent in a user's repo: if you see `git log` showing few commits over a long span of substantive work in the working tree, **flag it once** (don't repeat the flag every turn). That gap is a future incident waiting to happen — no baseline to bisect against, no clean state to revert to, no way to isolate which change caused which break. Suggest a checkpoint commit before starting invasive work, and offer to commit verified milestones as they land (still respecting the "only commit when explicitly asked" rule — *propose*, don't auto-commit).

The reason this rule earns its line in the global file: every other recovery technique (revert, bisect, stash, branch) presupposes that history exists at the resolution you need. **You cannot checkpoint after the fact.**

---

## Editing layer hygiene

Three rules that share one root cause: **operate at the layer where the edit is natural, not one layer below it.** When an operation seems to demand precision the medium can't give you, you are at the wrong layer — find the right one before continuing.

### Rule: Never paste multi-line code into a Windows shell

PowerShell parses `>`, `(`, `{`, `;`, `&` as redirects/separators. Pasting a multi-line code block creates one zero-byte file per token (each parenthesis, brace, or `>` becomes a redirect target). The pasted code does **not** execute, and the working tree fills with garbage filenames like `URL.revokeObjectURL(url)` or `LOG_CAP)`.

- For writing files: use the `Write` tool, an editor, or a single-quoted heredoc (`@'...'@` with `'@` at column 0). Never paste raw.
- For shell input that genuinely needs multiline: heredoc only.
- **Smoke alarm:** if `git status` shows untracked files whose names look like code fragments (parens, braces, identifiers with `.`), stop everything. Clean before any other operation. Those files contaminate every subsequent `git status`, hook trigger, and `Glob`.

### Rule: Treat bundled artifacts as read-only

If you find yourself making line-number-targeted edits to a single >100K-line file produced by a bundler (esbuild, webpack, rollup, parcel, vite, tsup, etc.) — **stop**. Surgical patches to bundles fail in three ways:

1. Line numbers are ephemeral; the next insert shifts everything below and your subsequent patches drift.
2. Decorator metadata, symbol tables, and minifier-renamed identifiers depend on lexical position and quietly corrupt under edits.
3. The next rebuild from source erases every patch.

Before patching: locate the source tree, find the build command, verify a clean rebuild reproduces the current artifact byte-for-byte (or close enough to map). If there is no source tree, that is a project-level red flag worth surfacing to the user before any further work — propose adding a build path, forking from upstream source, or building a separate extension point that doesn't require mutating the artifact.

### Rule: Manual multi-field deploys drift silently

When a deploy flow is "copy disk file → paste into UI field" — especially across multiple fields — the deployed copy will desync from disk eventually, and the failure mode looks identical to a code bug. Mitigations:

- A `VERSION` (or hash) constant the runtime can echo back. Bumping the constant is necessary but not sufficient — *verify it round-trips* on the next session, don't trust the bump.
- A single deploy script if the surface allows it (gh CLI, an API endpoint, a paste-helper).
- Document the deploy as a checklist with verification, not a procedure.

If the user is debugging a "the code doesn't behave as written" issue on a multi-paste deploy surface, **first** suspect drift between disk and runtime. Verify before assuming the disk source is wrong.

---

## Other global preferences

(Add further language-specific or workflow rules below. Keep this file tight — every line is loaded into every session.)
