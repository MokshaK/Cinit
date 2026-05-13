# PROJECT_WIKI_SCHEMA.md

> **Audience:** Any LLM agent (Claude, Cursor, Copilot, Aider, etc.) operating on this repository.
> **Status:** Authoritative. This file defines how the `/docs/wiki/` directory is created, consumed, and maintained.
> **Inspired by:** Andrej Karpathy's "LLM Wiki" pattern — treating documentation as the *compiled state* of a codebase, not an afterthought.

---

## 🚀 Bootstrap Protocol — RUN THIS FIRST

> **If you are an LLM reading this file, your very first action is to check whether the wiki has been bootstrapped in this repository, and if not, perform the bootstrap below before doing anything else the user asked.**
>
> This file ships in a "flat" state alongside `index.md` and `log.md` at the repository root. The bootstrap moves them into the schema-mandated structure and creates a `CLAUDE.md` bridge file. The bootstrap is **idempotent** — running it on an already-bootstrapped repo is a safe no-op.

### Step 0 — Detection

Run these four checks. Record yes/no for each:

1. Does `docs/wiki/index.md` exist?
2. Does `docs/wiki/log.md` exist?
3. Do `docs/wiki/architecture/`, `docs/wiki/modules/`, and `docs/wiki/decisions/` all exist as directories?
4. Does `CLAUDE.md` exist at the repository root?

**If all four answer YES:** the bootstrap is complete. Skip the rest of this section and proceed to §1 (Core Philosophy).

**If any answer NO:** perform Steps 1–6 below, in order.

### Step 1 — Create the directory structure

```bash
mkdir -p docs/wiki/architecture docs/wiki/modules docs/wiki/decisions
```

PowerShell equivalent:
```powershell
New-Item -ItemType Directory -Force -Path docs/wiki/architecture, docs/wiki/modules, docs/wiki/decisions
```

### Step 2 — Move the flat wiki pages into `docs/wiki/`

Move only if the source file is at the root **and** the destination does not already exist (idempotency guard). Prefer `git mv` so version history follows the file; fall back to `mv` if the file isn't yet tracked:

```bash
if [ -f index.md ] && [ ! -f docs/wiki/index.md ]; then
  git mv index.md docs/wiki/index.md 2>/dev/null || mv index.md docs/wiki/index.md
fi
if [ -f log.md ] && [ ! -f docs/wiki/log.md ]; then
  git mv log.md docs/wiki/log.md 2>/dev/null || mv log.md docs/wiki/log.md
fi
```

> ⚠️ **Do NOT move `PROJECT_WIKI_SCHEMA.md`.** It stays at the repository root permanently — it is the spec, not a wiki page.

### Step 3 — Pin the empty subdirectories

So `architecture/`, `modules/`, and `decisions/` survive into git even before they have content:

```bash
touch docs/wiki/architecture/.gitkeep docs/wiki/modules/.gitkeep docs/wiki/decisions/.gitkeep
```

### Step 4 — Create the `CLAUDE.md` bridge file

If `CLAUDE.md` does **not** already exist at the repo root, create it with **exactly** the content in the fenced block below — verbatim. The `## Wiki-First Workflow` section must appear word-for-word; the file as a whole, however, may also contain other sections (project-specific build/test/lint commands, language conventions, etc.) added by the user. Do not rewrite or "improve" the Wiki-First Workflow section itself.

````markdown
# Claude Code Instructions

## Wiki-First Workflow

This repository uses the LLM Wiki pattern, defined in `PROJECT_WIKI_SCHEMA.md`
at the repo root. The wiki at `/docs/wiki/` is the **Compiled State** of this
codebase — a tiered, evidence-anchored summary optimized for limited LLM
context windows.

### Before answering questions or making changes:

1. **Read `/docs/wiki/index.md` first.** Orient yourself in the content map.
2. **Drill down via links** to relevant module / architecture / decision pages.
3. **Read raw source only when the wiki is insufficient** — typically when
   writing a patch that requires exact line-level context, or when the wiki
   contradicts what you observe.

### After making code changes:

Follow the **Ingest Protocol** in `PROJECT_WIKI_SCHEMA.md` §3:
- Update the relevant `modules/*.md` page(s).
- Append an entry to `docs/wiki/log.md`.
- Add an ADR under `docs/wiki/decisions/` if the change reflects an
  architectural decision (new dependency, new pattern, breaking change).
- Run a contradiction sweep: grep the wiki for terms related to your change
  and fix anything that no longer matches reality.
- Wiki updates ride in the **same commit** as the code change.

### When asked to "lint the wiki":

Run the six-pass Linting Operation in `PROJECT_WIKI_SCHEMA.md` §5 and produce
a written report. Do not auto-edit pages without confirmation.

### Prime directive:

If the wiki disagrees with the code, the **code is right** — and the wiki
must be fixed. A half-stale wiki is worse than no wiki, because future
agents will trust it.
````

If `CLAUDE.md` *already exists*, do **not** overwrite it. Instead, check whether it already contains a `## Wiki-First Workflow` section. If not, append the body of the block above (everything from `## Wiki-First Workflow` onward) to the existing file.

### Step 5 — Append a bootstrap entry to `log.md`

Add a new entry at the **top** of `docs/wiki/log.md` (above any existing entries), using today's actual date and the repository's actual name. Template:

```markdown
## YYYY-MM-DD — Wiki bootstrapped in <repo-name>

- Moved `index.md` and `log.md` from repo root into `docs/wiki/`.
- Created `architecture/`, `modules/`, `decisions/` subdirectories.
- Generated `CLAUDE.md` bridge file at repo root.
- Wiki is now in skeletal state. **First Ingest pending** — see Appendix B of `PROJECT_WIKI_SCHEMA.md`.

**Wiki pages updated:** `index.md`, `log.md`
**Source files touched:** _none — bootstrap-only commit_
**Related ADR:** _none_

---
```

### Step 6 — Verify and report

Run a final structural check:

```bash
ls -la docs/wiki/ docs/wiki/architecture docs/wiki/modules docs/wiki/decisions
ls -la CLAUDE.md PROJECT_WIKI_SCHEMA.md
```

Then report to the user, in plain prose, in roughly this shape:

```
✅ Wiki bootstrap complete.

Created:
- docs/wiki/architecture/, docs/wiki/modules/, docs/wiki/decisions/
- CLAUDE.md at repo root  (or: "preserved existing CLAUDE.md, appended Wiki-First Workflow section")

Moved:
- index.md → docs/wiki/index.md
- log.md   → docs/wiki/log.md

Logged the bootstrap in docs/wiki/log.md.

Next step: run the First Ingest (Appendix B of PROJECT_WIKI_SCHEMA.md).
This walks the codebase, fills in the Content Map in index.md, drafts an
architecture overview, creates one stub per top-level module, and backfills
retroactive ADRs for any visible foundational decisions. Want me to do
that now?
```

After bootstrap, the rest of this file (§1 onwards) becomes the live spec for ongoing wiki maintenance.

### Note on Claude Code permissions

The bootstrap runs `mkdir`, `git mv`, `mv`, and `touch`. On Claude Code, each of these will trigger a permission prompt the first time. To avoid friction, the user (or the bootstrap agent, with permission) may add these to `.claude/settings.json` at the project root or `~/.claude/settings.json` for global allowlist:

```json
{
  "permissions": {
    "allow": [
      "Bash(mkdir:*)",
      "Bash(git mv:*)",
      "Bash(mv:*)",
      "Bash(touch:*)",
      "Bash(ls:*)"
    ]
  }
}
```

This is a convenience, not a requirement — the bootstrap works fine with manual approvals.

---

## 1. Core Philosophy

The wiki at `/docs/wiki/` is the **Compiled State** of this codebase. Source files are the *raw, uncompiled* truth; the wiki is the *distilled, queryable* truth — optimized for the limited context windows of LLM agents and the limited reading speed of humans.

### The Prime Directive

> **Before reading raw source files to answer a general question, you MUST first consult `/docs/wiki/index.md` and any wiki pages it points to.**

Raw source reads are *expensive* (in tokens, in attention dilution, in time) and *unstructured* (a 5,000-line file forces you to reconstruct intent from scratch every time). The wiki exists so you don't pay that cost on every turn.

### The Tiered Retrieval Model

When a task arrives, walk down this ladder and stop at the first rung that gives you a confident answer:

| Tier | Source | When to use |
|------|--------|-------------|
| 1 | `index.md` | Always. Orient yourself first. |
| 2 | `modules/<module>.md`, `architecture/*.md`, `decisions/*.md` | For "what does X do" / "why was X built this way" / "how does data flow." |
| 3 | `log.md` | For "when / why did this change" or "has this been tried before." |
| 4 | **Raw source files** (via Evidence Anchors in the wiki) | Only when you need to write a patch, debug a specific bug, or verify a claim the wiki cannot resolve. |

If you find yourself reaching tier 4 *without* having exhausted tiers 1–3, stop — you are wasting context.

### What the Wiki Is NOT

- Not auto-generated API docs (those go elsewhere; the wiki is human/LLM-readable narrative).
- Not a duplicate of the README (the README is for newcomers; the wiki is for working agents).
- Not a place for tutorials, marketing copy, or aspirational design ("things we'd like to build someday"). Aspirational items live in issue trackers.

---

## 2. Directory Structure

```
/docs/wiki/
├── index.md                    # Central hub. Content map. Entry point for every task.
├── log.md                      # Chronological record of architectural changes and ingests.
├── architecture/               # High-level system design.
│   ├── overview.md             # The 30-second mental model of the system.
│   ├── data-flow.md            # How data moves through the system end-to-end.
│   └── <topic>.md              # Cross-cutting concerns: auth, caching, deployment, etc.
├── modules/                    # One file per major module / package / component.
│   └── <module-name>.md        # Functionality, dependencies, state, evidence anchors.
└── decisions/                  # Architecture Decision Records (ADRs).
    └── NNNN-<slug>.md          # Zero-padded sequential ID, e.g. 0001-use-postgres.md
```

### File-by-File Contract

#### `index.md` — the hub
- A short orientation paragraph (3–5 sentences): what this project *is*.
- A linked content map of every other wiki file, grouped by section.
- A "How to use this wiki" callout pointing back to this schema.
- Last-updated timestamp (date only, ISO format: `YYYY-MM-DD`).

#### `log.md` — the chronological record
- Reverse-chronological (newest first).
- Each entry has: ISO date, one-line title, change summary (≤5 bullets), affected wiki pages, affected source files.
- Entries are append-only at the top; never edit historical entries except to fix factual errors (with a strikethrough + correction note).
- **Archive policy.** When `log.md` exceeds ~500 lines, move entries older than 12 months into `log-archive-YYYY.md` (one file per archived year). Replace the moved entries in `log.md` with a single pointer line: `> Entries from <year> and earlier moved to [log-archive-YYYY.md](./log-archive-YYYY.md).` Archive files follow the same format but are read-only thereafter.

#### `architecture/*.md` — the design layer
- One file per concern. Keep each focused; split when a file exceeds ~400 lines.
- Required sections: **Purpose**, **Components**, **Data Flow** (where applicable), **Evidence Anchors**, **Related Decisions**.
- Diagrams in Mermaid (renders in GitHub) or ASCII art. Avoid binary images.

#### `modules/*.md` — the implementation layer
- One file per major module. Filename matches the module's import path slug (e.g. `services-trading-engine.md` for `src/services/trading_engine/`).
- Required sections (see template below): **Responsibility**, **Public Interface**, **Dependencies**, **State Management**, **Evidence Anchors**, **Gotchas**.
- **Do NOT create module pages for generated, vendored, or build-artifact code** — e.g. `src/generated/`, `vendor/`, `node_modules/`, `__pycache__/`, transpilation output. If such a directory needs documentation (e.g. *how* code is generated), document it in `architecture/` as a single page about the generation pipeline, not per-file.

#### `decisions/*.md` — ADRs
- One decision per file. Numbering is sequential and never reused, even after a decision is superseded.
- Required sections: **Status** (Proposed / Accepted / Superseded by NNNN / Deprecated), **Context**, **Decision**, **Consequences**, **Alternatives Considered** (including ones that *failed* — this is where institutional memory lives).
- A superseded ADR is *not* deleted. It is marked superseded and the new ADR links back to it.

---

## 3. The Ingest Protocol

"Ingesting" = absorbing a code change into the wiki so the Compiled State stays in sync with reality. Run this protocol whenever you add a feature, refactor, fix a non-trivial bug, change a dependency, or alter system behavior.

### The Workflow

1. **Identify scope.** List the source files touched. Map each to its corresponding `modules/*.md` page (create one if it doesn't exist for a new module).
2. **Update module pages.** For each affected module:
   - Update **Responsibility** if behavior changed.
   - Update **Public Interface** if signatures changed.
   - Update **Dependencies** if imports changed.
   - Update **State Management** if state shape, ownership, or persistence changed.
   - Update or add **Evidence Anchors** to point at the new line numbers.
3. **Update architecture pages** if cross-cutting flow changed (data flow, auth path, deployment topology, etc.).
4. **Append to `log.md`** at the top:
   ```markdown
   ## YYYY-MM-DD — <one-line title>
   - Summary bullet 1 (≤20 words)
   - Summary bullet 2
   **Wiki pages updated:** modules/foo.md, architecture/data-flow.md
   **Source files touched:** src/foo/bar.py:42-120, src/baz/qux.ts:1-50
   **Related ADR:** decisions/0007-switch-to-redis.md (if applicable)
   ```
5. **Add or update an ADR** if the change reflects a real architectural decision (new dependency, new pattern, breaking change, deprecation). Trivial bugfixes do not need ADRs.
6. **Contradiction sweep.** Identify every symbol you changed and apply these specific greps:
   - **Renamed identifier** (`OrderRouter` → `RoutingService`): grep the wiki for **both** the old and the new name. Update every hit of the old name; verify every hit of the new name is correct.
   - **Deleted identifier**: grep the wiki for the old name. Every hit is either a fact to remove, or a "this used to do X" note that needs rewording.
   - **New identifier**: grep the wiki for *concept-adjacent* terms (e.g. for a new `RetryPolicy` class, grep "retry", "backoff", "redrive"). Every hit is a candidate place to link or cross-reference the new identifier.
   - **Changed signature**: grep the wiki for the function/method name. Verify each hit reflects the new signature.
   - **Changed file path or moved file**: grep the wiki for the old path. Update every Evidence Anchor.
   For any hit, ask: *"Does this still match reality after my change?"* If not, fix it in the same commit. Do **not** leave the wiki in a contradictory state — a half-stale wiki is worse than no wiki, because future agents trust it.
7. **Update `index.md`'s last-updated date** if you added new pages or restructured sections.

### When NOT to ingest
- Pure formatting changes, comment fixes, dependency version bumps with no behavior change, generated-file updates. These do not require wiki updates. (But if a dep bump *forces* code changes — e.g. a breaking API change — that *is* an ingest.)

### Commit Hygiene
- Wiki updates ride in the **same commit** (or same PR) as the code change that motivated them. Separating them is how drift starts.

---

## 4. Context Optimization Rules

The wiki only delivers value if it is *cheap to read* and *trustworthy*. These rules keep it that way.

### Rule 1 — Evidence Anchors are mandatory

Every non-trivial claim about the codebase must be followed by an Evidence Anchor: a pointer to the file (and line range, when stable) that backs the claim. Format:

```
[`src/services/auth/jwt.py:L42-L78`](../../src/services/auth/jwt.py#L42-L78)
```

This lets the next agent (or you, on a later turn) jump to raw source *only when needed*, instead of speculating or pre-loading the whole file.

**Anchor hygiene:**
- Prefer ranges over single lines (`L42-L78` not `L42`) — line numbers shift, ranges degrade more gracefully.
- For long-lived stable APIs, anchor to a function/class name in prose rather than line numbers: `the JwtVerifier class in src/auth/jwt.py`.
- During the contradiction sweep (step 6 above), verify anchors still point at the right code.

### Rule 2 — Succinct but technically dense

Target density: **one technical fact per sentence, no filler.** A wiki page is not a blog post.

- ✅ *"The `OrderRouter` dispatches to a venue adapter selected by `venue_priority` config; failures fall through to the next venue with exponential backoff (base 100ms, max 5 retries)."*
- ❌ *"The `OrderRouter` is responsible for routing orders. It is an important part of the system. It dispatches orders to venue adapters."*

If you can delete a sentence without losing a fact, delete it.

### Rule 3 — Page length budgets

| Page type | Soft cap | Hard cap |
|-----------|----------|----------|
| `modules/*.md` | 200 lines | 400 lines |
| `architecture/*.md` | 300 lines | 500 lines |
| `decisions/*.md` | 150 lines | 300 lines |
| `index.md` | 300 lines | 500 lines |

When you hit the hard cap, **split the page** rather than truncate. A 400-line module page usually means the module itself should be split, or that two concerns are tangled in one file — flag this in `log.md`. For `index.md` specifically, if the Content Map dominates the page length, split the tables (Modules, Decisions) out into `content-map.md` and link from `index.md`.

### Rule 4 — Cross-link liberally, duplicate sparingly

If two pages would say the same thing, one of them links to the other. Duplicated prose drifts. Single source of truth, even within the wiki.

### Rule 5 — No hedging language

Avoid "probably," "might," "should." If you don't know, write *"UNVERIFIED:"* and explain what would resolve it. Hedging looks like knowledge to a downstream LLM and is the #1 cause of cascading hallucination.

### Rule 6 — Write for the next agent, not for yourself

Assume the next reader has zero memory of this conversation. State acronyms on first use. Link to ADRs when referencing decisions. Define jargon.

---

## 5. The Linting Operation

A wiki untouched by linting rots. Run this operation **on demand** when the user asks (e.g. *"lint the wiki"*) and **proactively** when you notice symptoms during normal work. Output a written report; do not silently mutate.

### Lint Pass A — Hallucination Check (wiki-vs-code drift)

For each `modules/*.md` and `architecture/*.md` page:
1. Resolve every Evidence Anchor. Does the file still exist? Does the line range still contain the claimed code?
2. For each public interface listed, verify the signature matches source.
3. For each dependency listed, verify the import still exists.
4. For each "State Management" claim, verify the state shape still matches.

Report format per finding:
```
[DRIFT] modules/foo.md:L23 claims `processBatch(items, opts)`,
        but src/foo.py:L88 now reads `processBatch(items, opts, ctx)`.
        Suggested fix: update wiki to include `ctx` parameter.
```

### Lint Pass B — Orphan Pages

A page is an *orphan* if no other wiki page links to it (excluding `index.md`, which is the root, and `log.md`, which references everything). Orphans are usually a sign that the page was forgotten in a restructure.

Report format:
```
[ORPHAN] modules/legacy-cache.md is not linked from index.md or any other page.
         Either link it or move it to docs/wiki/_archive/ with a deprecation note.
```

### Lint Pass C — Missing Cross-References

For each major term in the codebase (modules, classes, key functions, config keys), grep the wiki. If a term appears in more than one page without a link to its canonical page, flag it.

Report format:
```
[XREF] "OrderRouter" mentioned in 4 pages; canonical page is modules/order-router.md.
       3 mentions are not linked: architecture/data-flow.md:L67, modules/risk-engine.md:L12, log.md:L142.
```

### Lint Pass D — Stale Log Entries

Scan `log.md` for entries older than 90 days that reference wiki pages no longer present. These are usually fine (history is history) but flag if a deleted page is referenced by *current* (non-archived) pages — that's a broken link, not just a stale log.

### Lint Pass E — Schema Conformance

For each module / architecture / ADR page, verify it has all the required sections defined in §2. Missing sections → flag.

### Lint Pass F — Dead Anchors

`grep` every Evidence Anchor URL. Any pointing to a file path that no longer exists in the repo is dead.

### Output

When the lint operation completes, post a single consolidated report grouped by severity (DRIFT > XREF > ORPHAN > SCHEMA > STALE > DEAD-ANCHOR), and ask the user whether to apply automated fixes. **Do not auto-edit pages without confirmation** — false positives in lint passes are common and silent edits erode trust in the wiki.

---

## Appendix A — Page Templates

### `modules/<n>.md` template

```markdown
# Module: <n>

**Path:** `src/path/to/module/`
**Last verified:** YYYY-MM-DD

## Responsibility
One paragraph. What does this module own? What does it explicitly *not* own?

## Public Interface
- `functionA(args) -> ReturnType` — one-line description. [`path/file.ext:L10-L40`](...)
- `ClassB` — one-line description. [`path/file.ext:L50-L120`](...)

## Dependencies
- **Internal:** `modules/other-module.md`, `modules/third-module.md`
- **External:** `requests`, `redis-py>=5.0`

## State Management
What state does this module own? Where is it stored? Who else can mutate it?

## Evidence Anchors
- Entry point: [`src/path/main.ext:L1-L30`](...)
- Core logic: [`src/path/core.ext:L50-L200`](...)
- Tests: [`tests/path/test_core.ext`](...)

## Gotchas
- Non-obvious behaviors, performance cliffs, threading constraints, retry semantics, etc.

## Related Decisions
- [ADR-0007: Why we use a thread pool here](../decisions/0007-thread-pool.md)
```

### `decisions/NNNN-<slug>.md` template

```markdown
# ADR-NNNN: <title>

**Status:** Proposed | Accepted | Superseded by ADR-MMMM | Deprecated
**Date:** YYYY-MM-DD

## Context
What problem are we solving? What forces are at play?

## Decision
What did we decide? Be specific and imperative.

## Consequences
- Positive: ...
- Negative: ...
- Neutral / unknown: ...

## Alternatives Considered
- **Option A** — why rejected. (Include options that were *tried and failed* — this is the institutional memory that prevents re-litigation.)
- **Option B** — why rejected.

## Implementation Notes
Reality is usually messier than the decision. Use this section to record where execution diverged from the original plan and why. Examples:
- *"Decided to use Postgres for all persistence (above). In practice, session state moved to Redis on 2026-03-14 because of latency on hot paths — see log entry."*
- *"Originally planned to enforce schema migrations via Alembic; ended up using raw SQL migrations because Alembic's autogenerate produced too many false positives on JSONB columns."*

Leave this section empty (`_none_`) for new ADRs. Update it whenever the implementation drifts from the original decision — but do **not** edit the **Decision** section to retroactively match. The point of an ADR is to preserve the original choice; drift is recorded separately.
```

---

## Appendix B — Quickstart for the First Ingest

When this schema is first applied to an existing codebase (after the Bootstrap Protocol has placed files correctly):

1. Read the README and top-level directory structure.
2. Update `index.md` with a real content map (replace the `TODO (first-ingest)` placeholders).
3. Create one `modules/*.md` per top-level package/module — start with one paragraph each, expand on demand.
4. Create `architecture/overview.md` and `architecture/data-flow.md` even if minimal.
5. Backfill ADRs for any decision visible in the codebase that future agents will need to understand (choice of database, framework, deployment target, etc.). Mark these `Status: Accepted (retroactive)`.
6. Append a `log.md` entry: `"YYYY-MM-DD — First Ingest complete."`

The first ingest does not need to be exhaustive. It needs to be *usable*. Subsequent ingests will fill the gaps as code changes touch each area.

---

*End of schema. Updates to this file are themselves architectural decisions and should be recorded as ADRs.*
