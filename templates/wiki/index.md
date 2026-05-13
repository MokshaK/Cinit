# Project Wiki — Index

> **This is the entry point for any LLM agent or human working on this codebase.**
> Read this page first. Follow links from here to module pages, architecture pages, and decision records before reading raw source files.
> See [`PROJECT_WIKI_SCHEMA.md`](../../PROJECT_WIKI_SCHEMA.md) for the rules that govern this directory.

**Last updated:** 2026-04-26
**Wiki status:** 🌱 *Skeleton — populated with placeholders. The first agent with full repository access should run the "First Ingest" protocol from Appendix B of the schema.*

---

## What This Project Is

> **TODO (first-ingest):** Replace this block with 3–5 sentences describing what the project does, who uses it, and the core technical stack. Pull from the README if one exists.

```
[ ] Project name:
[ ] One-line description:
[ ] Primary language(s) / framework(s):
[ ] Deployment target:
[ ] Entry point file(s):
```

---

## How to Use This Wiki

1. **Orient** — skim this page to find the area relevant to your task.
2. **Drill down** — open the linked module / architecture / decision page.
3. **Anchor out** — only follow Evidence Anchors to raw source when the wiki is insufficient.
4. **Ingest** — when you change code, follow the Ingest Protocol (§3 of the schema) to keep this wiki honest.
5. **Lint** — when asked, run the Linting Operation (§5 of the schema) and report findings.

---

## Content Map

### 🏛 Architecture
High-level system design, cross-cutting concerns, and end-to-end flows.

- [ ] [`architecture/overview.md`](./architecture/overview.md) — *Not yet written.* The 30-second mental model.
- [ ] [`architecture/data-flow.md`](./architecture/data-flow.md) — *Not yet written.* End-to-end data movement.

> **TODO (first-ingest):** Add architecture pages for cross-cutting concerns identified in the codebase: auth, caching, persistence, deployment, observability, etc.

### 📦 Modules
One page per major module / package / component.

> **TODO (first-ingest):** Walk the top-level source directories. For each package or significant module, create `modules/<slug>.md` from the template in Appendix A of the schema, and link it here.

| Module | Page | Path | Status |
|--------|------|------|--------|
| _none yet_ | — | — | — |

### 📐 Decisions (ADRs)
Architecture Decision Records — *why* the system is shaped the way it is.

> **TODO (first-ingest):** Backfill retroactive ADRs for foundational choices visible in the codebase (language, framework, database, deployment target, key external dependencies). Mark each as `Status: Accepted (retroactive)`.

| # | Title | Status | Date |
|---|-------|--------|------|
| _none yet_ | — | — | — |

### 📜 Log
- [`log.md`](./log.md) — Chronological record of all architectural changes and ingests.

---

## Glossary

> **TODO (first-ingest):** Define project-specific acronyms, domain terms, and internal jargon. Every term used in more than one wiki page should appear here once.

| Term | Definition |
|------|------------|
| _none yet_ | — |

---

## Conventions Used in This Wiki

- **Evidence Anchors** look like [`src/path/file.ext:L42-L78`](#) and link to specific line ranges in source.
- **Status badges** on pages: 🌱 skeleton • 🚧 partial • ✅ verified-recent • ⚠️ stale (flagged by the Linting Operation as needing re-verification).
- **`UNVERIFIED:`** prefix marks any claim the author could not confirm at write-time. Resolve or remove on next visit.
- **Cross-references** to ADRs use the form `ADR-NNNN`.

---

## When in Doubt

- If the wiki disagrees with the code, **the code is right** — and the wiki must be fixed (this is a DRIFT lint finding; see §5 of the schema).
- If two wiki pages disagree, the more recently updated one is presumed correct, but flag the contradiction in `log.md`.
- If you cannot find the information you need in the wiki, that is itself a finding — note it in your task output and consider adding a stub page after consulting the relevant source.
