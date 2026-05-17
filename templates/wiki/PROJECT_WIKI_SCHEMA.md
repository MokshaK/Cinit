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

Run these five checks. Record yes/no for each:

1. Does `docs/wiki/index.md` exist?
2. Does `docs/wiki/log.md` exist?
3. Does `docs/wiki/lessons.md` exist?
4. Do `docs/wiki/architecture/`, `docs/wiki/modules/`, and `docs/wiki/decisions/` all exist as directories?
5. Does `CLAUDE.md` exist at the repository root?

**If all five answer YES:** the bootstrap is complete. Skip the rest of this section and proceed to §1 (Core Philosophy).

**If any answer NO:** perform Steps 1–6 below, in order.

> **Shell note.** Commands below are shown for **PowerShell** first (Windows default) and **bash** second (macOS / Linux / WSL). Pick the matching set; don't mix them.

### Step 1 — Create the directory structure

PowerShell:
```powershell
New-Item -ItemType Directory -Force -Path docs/wiki/architecture, docs/wiki/modules, docs/wiki/decisions | Out-Null
```

bash:
```bash
mkdir -p docs/wiki/architecture docs/wiki/modules docs/wiki/decisions
```

### Step 2 — Move the flat wiki pages into `docs/wiki/`

Move only if the source file is at the root **and** the destination does not already exist (idempotency guard). Prefer `git mv` so version history follows the file; fall back to `Move-Item` / `mv` if the file isn't yet tracked.

PowerShell:
```powershell
foreach ($f in 'index.md','log.md','lessons.md') {
  if ((Test-Path $f) -and -not (Test-Path "docs/wiki/$f")) {
    git mv $f "docs/wiki/$f" 2>$null
    if ($LASTEXITCODE -ne 0) { Move-Item $f "docs/wiki/$f" }
  }
}
```

bash:
```bash
for f in index.md log.md lessons.md; do
  if [ -f "$f" ] && [ ! -f "docs/wiki/$f" ]; then
    git mv "$f" "docs/wiki/$f" 2>/dev/null || mv "$f" "docs/wiki/$f"
  fi
done
```

> ⚠️ **Do NOT move `PROJECT_WIKI_SCHEMA.md`.** It stays at the repository root permanently — it is the spec, not a wiki page.

### Step 3 — Pin the empty subdirectories

So `architecture/`, `modules/`, and `decisions/` survive into git even before they have content:

PowerShell:
```powershell
'docs/wiki/architecture/.gitkeep','docs/wiki/modules/.gitkeep','docs/wiki/decisions/.gitkeep' |
  ForEach-Object { New-Item -ItemType File -Force -Path $_ | Out-Null }
```

bash:
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

### When you (or the user) learn something the hard way:

Append to `docs/wiki/lessons.md` per `PROJECT_WIKI_SCHEMA.md` §6. Capture
threshold is loose during the project (anything that cost >30min or generated
explicit feedback). Promotion to global rules happens at end-of-project via
`/lessons-review`, not unilaterally.

### When asked to "lint the wiki":

Run the six-pass Linting Operation in `PROJECT_WIKI_SCHEMA.md` §5 and produce
a written report. Do not auto-edit pages without confirmation.

### When asked to "review lessons":

Run the Lessons Review Ritual in `PROJECT_WIKI_SCHEMA.md` §6. Propose
promotions; never auto-edit global rules.

### Prime directive:

If the wiki disagrees with the code, the **code is right** — and the wiki
must be fixed. A half-stale wiki is worse than no wiki, because future
agents will trust it.
````

If `CLAUDE.md` *already exists*, do **not** overwrite it. Instead, check whether it already contains a `## Wiki-First Workflow` section. If not, append the body of the block above (everything from `## Wiki-First Workflow` onward) to the existing file.

### Step 5 — Update the seed entry in `log.md`

The flat `log.md` ships with a seed entry titled `## YYYY-MM-DD — Wiki bootstrapped`. Replace `YYYY-MM-DD` with today's actual date and append the repository's actual name to the title: `## 2026-05-17 — Wiki bootstrapped in my-cool-repo`. The body is already correct — do not rewrite it.

If `log.md` already has any non-bootstrap entries above the seed entry (idempotency case: bootstrap was run, work was logged, you're re-running bootstrap), do **not** add another bootstrap entry — leave history alone.

### Step 6 — Verify and report

Run a final structural check:

PowerShell:
```powershell
Get-ChildItem docs/wiki/, docs/wiki/architecture, docs/wiki/modules, docs/wiki/decisions
Get-ChildItem CLAUDE.md, PROJECT_WIKI_SCHEMA.md
```

bash:
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
The required minimum is small — fill in the "What This Project Is" block
in index.md, write one-paragraph module pages for the top three packages,
and log the completion. Want me to do that now?
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
├── lessons.md                  # Project-local lessons learned. Reviewed at project close (§6).
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

#### `lessons.md` — the project-local lessons log
- Append-only record of *what we learned the hard way* during this project. Format and capture criteria: see §6.
- Captures incidents that cost real time/effort, generated user feedback, or required undoing work. Each entry includes the incident, root cause, project-local rule, and a `Generalizable?` field (`no` / `maybe` / `yes`) that gates downstream promotion.
- **Not edited destructively.** Older entries may be marked `[resolved]` or `[superseded by ADR-NNNN]` but the original wording stays.
- **Reviewed at project close** via the ritual in §6. Promotions to global rules are user-approved, never automatic.

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
- Required sections: **Status** (Proposed / Accepted / Superseded by NNNN / Deprecated / Observed), **Context**, **Decision**, **Consequences**, **Alternatives Considered** (including ones that *failed* — this is where institutional memory lives).
- A superseded ADR is *not* deleted. It is marked superseded and the new ADR links back to it.
- **Threshold for writing one:** if reversing this decision would take more than a day of work, or if the choice locks in a contract that other modules or external systems depend on, write an ADR. Trivial bugfixes, version bumps, and one-file refactors do not need one.
- **Retroactive ADRs.** When backfilling for decisions made before the wiki existed, use `Status: Observed` (not `Accepted (retroactive)`). The **Alternatives Considered** section should explicitly state which parts of the rationale were reconstructed from git history vs. invented — invented rationale undermines the institutional-memory value of the ADR format.

---

## 3. The Ingest Protocol

"Ingesting" = absorbing a code change into the wiki so the Compiled State stays in sync with reality. Run this protocol whenever you add a feature, refactor, fix a non-trivial bug, change a dependency, or alter system behavior.

### Pre-Ingest Gate — tests must be green

An ingest captures a *completed* code change. A change that leaves tests red is not complete.

- **If the global `run_tests.py` hook is installed,** the gate is enforced structurally — the hook ran the suite after every edit and would have surfaced any failure. Run the full suite once more before logging, then proceed.
- **If the hook is not installed** (or has been project-disabled), run the test command yourself before starting the workflow below. If anything is red, **stop**. Fix the code or revert. Re-run. Only then ingest.
- **If the touched code has no tests at all,** decide now whether that's acceptable for this change. Trivial / exploratory: note it in the log entry. Production-path code: write a test before ingesting. A new test must fail before its implementation lands — a green-on-stub test is a tautology, not coverage.

This gate exists because a wiki entry that says "shipped feature X" while X's tests are red is worse than no entry — it hides a known break behind documentation prose.

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
8. **Append to `lessons.md` if the change taught you something.** Don't force it — only if a real lesson surfaced (an incident, a non-obvious gotcha, a corrected mistake). Capture criteria are in §6; the test is *"would I want to know this on a future project?"* Skip if the answer is no. Multiple lessons in one ingest are fine and common during hard debugging sessions.

### When NOT to ingest
- Pure formatting changes, comment fixes, dependency version bumps with no behavior change, generated-file updates. These do not require wiki updates. (But if a dep bump *forces* code changes — e.g. a breaking API change — that *is* an ingest.)

### Commit Hygiene
- Wiki updates ride in the **same commit** (or same PR) as the code change that motivated them. Separating them is how drift starts.

---

## 4. Context Optimization Rules

The wiki only delivers value if it is *cheap to read* and *trustworthy*. These rules keep it that way.

### Rule 1 — Evidence Anchors are mandatory

Every non-trivial claim about the codebase must be followed by an Evidence Anchor: a pointer to the source that backs the claim. There are two anchor formats — **prefer the symbol anchor in almost all cases.**

**Symbol anchor (default).** Refer to a stable named entity in the file:

```
the `JwtVerifier` class in [`src/services/auth/jwt.py`](../../src/services/auth/jwt.py)
the `validate_session()` function in [`src/services/auth/jwt.py`](../../src/services/auth/jwt.py)
```

Symbol anchors survive refactors. As long as the symbol still exists at the named path, the anchor is correct. Any reader (human or agent) can find it with a single grep.

**Line-range anchor (fallback, use sparingly).** Only when:
- The claim is about a specific block of code with no named symbol (e.g. a long inline expression, a section of a config file, a SQL DDL fragment).
- The file is unusually stable — schema files, license headers, vendored snapshots.

```
[`src/services/auth/jwt.py:L42-L78`](../../src/services/auth/jwt.py#L42-L78)
```

Line numbers shift on every insert above the anchor. Ranges drift as fast as single lines — they do not "degrade more gracefully." Plan for line-range anchors to rot within weeks on active files, and replace them with symbol anchors when the contradiction sweep catches the rot.

**Anchor hygiene:**
- One Evidence Anchor per claim is enough — don't stack three different ways to get to the same code.
- During the contradiction sweep (Ingest Protocol §3 step 6), verify the symbol still exists at the named path. If it was renamed, update the anchor; if it was deleted, update or remove the claim.
- An anchor that points at a file but not a symbol is the weakest form — acceptable for "see also" pointers, not for load-bearing claims.

### Rule 2 — Succinct but technically dense

Target density: **one technical fact per sentence, no filler.** A wiki page is not a blog post.

- ✅ *"The `OrderRouter` dispatches to a venue adapter selected by `venue_priority` config; failures fall through to the next venue with exponential backoff (base 100ms, max 5 retries)."*
- ❌ *"The `OrderRouter` is responsible for routing orders. It is an important part of the system. It dispatches orders to venue adapters."*

If you can delete a sentence without losing a fact, delete it.

### Rule 3 — Page length budgets

The real constraint is **context-window economy**: when an agent reads a page, it should leave room for the source files the page anchors to. A 400-line module page that ships with 2,000 lines of anchored source is a 2,400-line read on what was supposed to be a "summary" lookup.

Rough budgets (treat as defaults, not laws):

| Page type | Comfortable | Reconsider at |
|-----------|-------------|---------------|
| `modules/*.md` | ≤200 lines | ≥400 lines |
| `architecture/*.md` | ≤300 lines | ≥500 lines |
| `decisions/*.md` | ≤150 lines | ≥300 lines |
| `index.md` | ≤300 lines | ≥500 lines |

When a page crosses the "reconsider" threshold, **split rather than truncate**. A long module page usually means the module itself should be split, or that two concerns are tangled in one file — flag this in `log.md`. For `index.md`, if the Content Map dominates the page length, split the tables (Modules, Decisions) out into `content-map.md` and link from `index.md`.

If you have a legitimate reason to keep a page longer (e.g. a single ADR whose Alternatives Considered section is genuinely the load-bearing institutional memory), note the reason at the top of the page and move on. Don't truncate facts to hit a number.

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

## 6. The Lessons Review Ritual

The wiki captures *what* was built and *why*. The lessons log captures *what we learned the hard way doing it* — incidents, surprising failure modes, choices that aged badly. The ritual below turns those project-local lessons into either project archive material, durable user memories, or (rarely) global rules.

### When to capture (intra-project, ongoing)

Append to `lessons.md` whenever **at least one** of these is true:

- An incident cost >30 minutes of wasted or redone work.
- The user gave explicit corrective feedback ("no, don't do that") or surprising positive feedback ("yes, exactly — keep doing that").
- A commit had to be undone, reverted, or hot-fixed within a session.
- The agent caught and corrected its own mistake mid-task and the mistake would plausibly recur.
- A user-perceived bug turned out to be runtime-state or premise issue — that's a lesson about diagnosis.

Capture is **deliberately cheap**: write the entry quickly, don't agonize over wording. Filtering happens at review, not at capture.

### Entry format

Every lessons.md entry must include these fields. The `Generalizable?` field is load-bearing — it gates promotion downstream.

```markdown
## YYYY-MM-DD — Short title

**Triggered by:** The concrete incident, not the abstraction. What happened, what was the symptom, how was it discovered.
**Cost:** Time / effort / scope of impact. Be specific: "~45min retraced steps" beats "some time."
**Root cause:** What conditions made this possible. Often different from the trigger.
**Local rule (this project):** What to do next time *here*. Project-specific is fine.
**Generalizable?:** `no` / `maybe` / `yes` — with one sentence on why.
**Candidate global rule:** *(only if `yes` or `maybe`)* The rule drafted in CLAUDE.md voice. ≤3 sentences.
```

Skip the **Candidate global rule** field for `no` entries — they're project archive material from day one.

### Promotion tiers

A lesson lives in one of three states. Promotion is one-way per cycle.

**Tier 1 — `lessons.md` (project-local).** Default state. No further action required.

**Tier 2 — User memory (`~/.claude/projects/.../memory/feedback_*.md`).** Promoted at end-of-project review when:
- The lesson was marked `Generalizable?: yes` or `maybe`, AND
- Cost was real (saved >1 hour OR averted a shipping bug OR averted an incident), AND
- The rule has a concrete trigger and concrete action, AND
- It doesn't duplicate an existing memory or CLAUDE.md rule.

**Tier 3 — Global CLAUDE.md.** Promoted from Tier 2 only when:
- Confirmed in ≥2 separate projects or project archetypes, AND
- Saves >1 hour per incident, AND
- The "would I write this rule from scratch if it didn't exist?" gut check passes, AND
- Either the global CLAUDE.md is under 250 lines, or this rule displaces a weaker existing rule.

**Disqualifying at all tiers:**
- Project-specific facts ("the FOO API requires X header").
- Tool-version-specific patches ("Python 3.13.2 has bug Y").
- Style preferences with no measured cost.
- Anything that reduces to "be more careful."

### The end-of-project ritual (`/lessons-review`)

When invoked, the ritual:

1. Reads `docs/wiki/lessons.md` in full.
2. For each entry marked `Generalizable?: yes` or `maybe`:
   - Presents the incident, the candidate global rule (in CLAUDE.md voice), and a conflict check against existing memories + CLAUDE.md sections.
   - Suggests a tier (1/2/3) with reasoning.
3. For each candidate, the user decides: **promote** / **revise then promote** / **keep at current tier** / **kill (not actually a lesson)**.
4. On `promote` to Tier 2: agent drafts a `feedback_*.md` memory file, user reviews, then it's saved.
5. On `promote` to Tier 3: agent drafts the CLAUDE.md edit (including which existing rule, if any, gets displaced), user reviews, then it's applied.
6. **Auto-edits are forbidden.** The ritual proposes; the user confirms each change.

### Annual growth budget

Global CLAUDE.md should not grow by more than **5 new rules per year**. Hard cap, by convention. If you have a 6th candidate and you're at or over 250 lines, the candidate either displaces an existing rule or waits for the next cycle.

If the budget feels tight, the bar at Tier 3 is too low — tighten the "would I write this from scratch?" check.

### When to skip the ritual

- Project ended in <1 week with no real friction. Lessons.md is empty or near-empty. Skip.
- All lessons.md entries are marked `Generalizable?: no`. Skip; archive the file with the project.
- You ran the ritual within the last 3 months on a related project. Defer until enough new material has accumulated.

---

## Appendix A — Page Templates

### `modules/<n>.md` template

```markdown
# Module: <n>

**Path:** `src/path/to/module/`

## Responsibility
One paragraph. What does this module own? What does it explicitly *not* own?

## Public Interface
- `functionA(args) -> ReturnType` — one-line description. The `functionA` function in [`path/file.ext`](...)
- `ClassB` — one-line description. The `ClassB` class in [`path/file.ext`](...)

## Dependencies
- **Internal:** `modules/other-module.md`, `modules/third-module.md`
- **External:** `requests`, `redis-py>=5.0`

## State Management
What state does this module own? Where is it stored? Who else can mutate it?

## Evidence Anchors
- Entry point: the `main()` function in [`src/path/main.ext`](...)
- Core logic: the `<ClassOrFunctionName>` symbol in [`src/path/core.ext`](...)
- Tests: [`tests/path/test_core.ext`](...)

## Gotchas
- Non-obvious behaviors, performance cliffs, threading constraints, retry semantics, etc.

## Related Decisions
- [ADR-0007: Why we use a thread pool here](../decisions/0007-thread-pool.md)
```

> No `Last verified` field. A date with no automation behind it is aspirational, not data — the contradiction sweep during each ingest (§3 step 6) is the verification mechanism that actually runs. If you want freshness signal, derive it from `git log -1 -- <anchored-file>` at lint time.

### `decisions/NNNN-<slug>.md` template

```markdown
# ADR-NNNN: <title>

**Status:** Proposed | Accepted | Superseded by ADR-MMMM | Deprecated | Observed
**Date:** YYYY-MM-DD

> **`Observed`** is for retroactive ADRs — decisions made before the wiki existed.
> Mark every claim in **Alternatives Considered** as either *(from git history)*,
> *(from code comments / docs)*, *(from user recall)*, or *(reconstructed)*.
> Reconstructed rationale is honest speculation, not institutional memory.

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

**Required minimum (do these before declaring First Ingest complete):**

1. Read the README and top-level directory structure.
2. Fill in the "What This Project Is" block in `index.md` — replace placeholders with real values (project name, one-line description, language/framework, entry point, test command).
3. Create one `modules/*.md` per **top-three** packages/modules (by size or importance) — one paragraph each, with a single Evidence Anchor pointing at the entry symbol.
4. Append a `log.md` entry: `"YYYY-MM-DD — First Ingest complete."`
5. Leave `lessons.md` empty — entries accumulate during the project, not at ingest time.

**Optional, do as code-touching work brings you near each area:**

5. Architecture pages (`overview.md`, `data-flow.md`) when you next touch a cross-cutting concern.
6. Additional `modules/*.md` pages when you next edit a module that doesn't have one. Don't pre-build pages for code you haven't read; you'll just produce placeholders that lie by omission.
7. **Retroactive ADRs.** Only backfill an ADR when (a) a current task depends on understanding a past decision and (b) the rationale is recoverable from git history, code comments, or explicit user recall. Use `Status: Observed` and mark which parts of the rationale were reconstructed vs. invented. Do **not** backfill speculatively to "complete" the wiki — invented rationale is worse than a missing ADR.

The first ingest does not need to be exhaustive. It needs to be *usable*. Subsequent ingests fill the gaps as code changes touch each area. Resist the urge to mass-author placeholders — every `modules/*.md` you create without reading the module is a future drift-lint finding.

---

*End of schema. Updates to this file are themselves architectural decisions and should be recorded as ADRs.*
