# Project Wiki — Change Log

> Reverse-chronological record of architectural changes and wiki ingests.
> Newest entries at the top. Append-only — historical entries are never edited except to correct factual errors (with a strikethrough and dated correction note).
> **Archive policy:** when this file exceeds ~500 lines, move entries older than 12 months into `log-archive-YYYY.md` per the rule in §2 of the schema.
> Format and rules: see §3 of [`PROJECT_WIKI_SCHEMA.md`](../../PROJECT_WIKI_SCHEMA.md).

---

## 2026-04-26 — Wiki initialized

- Created `/docs/wiki/` directory with the schema-mandated structure.
- Authored skeletal `index.md` and `log.md`.
- Schema authored at repository root: [`PROJECT_WIKI_SCHEMA.md`](../../PROJECT_WIKI_SCHEMA.md).
- `architecture/`, `modules/`, and `decisions/` subdirectories are reserved but empty pending the **First Ingest** (see Appendix B of the schema).

**Wiki pages updated:** `index.md`, `log.md`
**Source files touched:** _none — documentation-only commit_
**Related ADR:** _none yet_

**Next action for the next agent:** Run the First Ingest. Walk the repository, populate the Content Map in `index.md`, draft `architecture/overview.md`, create one `modules/*.md` stub per top-level package, and backfill retroactive ADRs for any foundational decisions visible in the codebase. Append a new entry to this log when done.

---

<!--
ENTRY TEMPLATE — copy this block above the most recent entry when ingesting a change:

## YYYY-MM-DD — <one-line title>

- Summary bullet 1 (≤20 words, technical fact)
- Summary bullet 2
- Summary bullet 3

**Wiki pages updated:** modules/foo.md, architecture/data-flow.md
**Source files touched:** src/foo/bar.py:L42-L120, src/baz/qux.ts:L1-L50
**Related ADR:** decisions/NNNN-slug.md (omit if none)

---
-->
