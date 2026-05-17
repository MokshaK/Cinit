# Project Wiki — Change Log

> Reverse-chronological record of architectural changes and wiki ingests.
> Newest entries at the top. Append-only — historical entries are never edited except to correct factual errors (with a strikethrough and dated correction note).
> **Archive policy:** when this file exceeds ~500 lines, move entries older than 12 months into `log-archive-YYYY.md` per the rule in §2 of the schema.
> Format and rules: see §3 of [`PROJECT_WIKI_SCHEMA.md`](../../PROJECT_WIKI_SCHEMA.md).

---

## YYYY-MM-DD — Wiki bootstrapped

- `/docs/wiki/` directory created with the schema-mandated structure.
- Skeletal `index.md` and `log.md` in place; `architecture/`, `modules/`, `decisions/` subdirectories reserved.
- First Ingest not yet run — see Appendix B of [`PROJECT_WIKI_SCHEMA.md`](../../PROJECT_WIKI_SCHEMA.md). Bootstrap protocol updates the date in this entry on first run.

**Wiki pages updated:** `index.md`, `log.md`
**Source files touched:** _none — bootstrap-only_
**Related ADR:** _none_

---

<!--
ENTRY TEMPLATE — copy this block above the most recent entry when ingesting a change.
Use symbol anchors (the `Foo` class in src/path/file.ext) where possible; line-range anchors only when no named symbol exists.

## YYYY-MM-DD — <one-line title>

- Summary bullet 1 (≤20 words, technical fact)
- Summary bullet 2
- Summary bullet 3

**Wiki pages updated:** modules/foo.md, architecture/data-flow.md
**Source files touched:** the `Bar` class in src/foo/bar.py, the `qux()` function in src/baz/qux.ts
**Tests:** `<command>` ✅ green | <N> added | none required (doc-only)
**Related ADR:** decisions/NNNN-slug.md (omit if none)

---
-->
