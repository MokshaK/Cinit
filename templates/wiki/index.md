# Project Wiki — Index

> **This is the entry point for any LLM agent or human working on this codebase.**
> Read this page first. Follow links from here to module pages, architecture pages, and decision records before reading raw source files.
> See [`PROJECT_WIKI_SCHEMA.md`](../../PROJECT_WIKI_SCHEMA.md) for the rules that govern this directory.

**Wiki status:** 🌱 *Skeleton — fill in the "What This Project Is" block and at least three module pages before claiming First Ingest complete. See Appendix B of the schema.*

---

## What This Project Is

> Replace the placeholders below with real values. This block is the single most-read section of the wiki — agents and humans both check it first.

```
[ ] Project name:
[ ] One-line description:
[ ] Primary language(s) / framework(s):
[ ] Entry point file(s):
[ ] Test command:                    # e.g. `uv run pytest`, `pnpm test`, `cargo test`
```

---

## How to Use This Wiki

1. **Orient** — skim this page to find the area relevant to your task.
2. **Drill down** — open the linked module / architecture / decision page.
3. **Anchor out** — only follow Evidence Anchors to raw source when the wiki is insufficient.
4. **Ingest** — when you change code, follow the Ingest Protocol (§3 of the schema) to keep this wiki honest. Tests for the touched modules must be green before an ingest is logged (Pre-Ingest Gate in §3).
5. **Lint** — when asked, run the Linting Operation (§5 of the schema) and report findings.

---

## Content Map

### 🏛 Architecture
High-level system design, cross-cutting concerns, and end-to-end flows. Add pages here as code-touching work brings you near each concern — don't pre-author placeholders.

| Page | Path | Status |
|------|------|--------|
| _none yet_ | — | — |

### 📦 Modules
One page per major module / package / component. Filename matches the import-path slug. Create on-demand as you touch each module; the First Ingest only requires the top three.

| Module | Page | Path | Status |
|--------|------|------|--------|
| _none yet_ | — | — | — |

### 📐 Decisions (ADRs)
Architecture Decision Records — *why* the system is shaped the way it is. Backfill retroactively only when a current task depends on understanding a past decision (see Appendix B of the schema).

| # | Title | Status | Date |
|---|-------|--------|------|
| _none yet_ | — | — | — |

### 📜 Log
- [`log.md`](./log.md) — Chronological record of all architectural changes and ingests.

---

## Glossary

Define project-specific acronyms, domain terms, and internal jargon as they appear. Every term used in more than one wiki page should appear here once. Empty is fine until the second usage.

| Term | Definition |
|------|------------|
| _none yet_ | — |

---

## Conventions Used in This Wiki

- **Evidence Anchors** prefer the symbol form: *the `Foo` class in [`src/path/file.ext`](#)*. Line-range anchors (`src/path/file.ext:L42-L78`) are a fallback for unnamed blocks — they rot fast. See §4 Rule 1 of the schema.
- **Status badges** on pages: 🌱 skeleton • 🚧 partial • ✅ verified-recent • ⚠️ stale (flagged by the Linting Operation as needing re-verification).
- **`UNVERIFIED:`** prefix marks any claim the author could not confirm at write-time. Resolve or remove on next visit.
- **Cross-references** to ADRs use the form `ADR-NNNN`.

---

## When in Doubt

- If the wiki disagrees with the code, **the code is right** — and the wiki must be fixed (this is a DRIFT lint finding; see §5 of the schema).
- If the code disagrees with its own tests, **the code is wrong** — do not document a feature whose tests are red. Fix the code, re-run tests, then ingest. A wiki page asserting behavior the test suite rejects is worse than a missing page.
- If two wiki pages disagree, the more recently updated one is presumed correct, but flag the contradiction in `log.md`.
- If you cannot find the information you need in the wiki, that is itself a finding — note it in your task output and consider adding a stub page after consulting the relevant source.
