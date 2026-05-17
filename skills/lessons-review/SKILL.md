---
name: lessons-review
description: End-of-project review of `docs/wiki/lessons.md`. Proposes which lessons should promote to user memory (Tier 2) or global CLAUDE.md rules (Tier 3). Never auto-edits global rules — proposes; user confirms each promotion.
---

# Lessons Review Ritual

This skill implements §6 of `PROJECT_WIKI_SCHEMA.md` — the end-of-project ritual that turns project-local lessons into durable user memories or (rarely) global rules.

## When to invoke

Run this skill when:
- A project is wrapping up and `docs/wiki/lessons.md` has accumulated entries.
- The user explicitly asks to "review lessons" or runs `/lessons-review`.
- It has been >3 months since the last review across any project on this machine.

**Do not run** when:
- `lessons.md` is empty or contains only `_No entries yet_`.
- Every entry is marked `Generalizable?: no` — these are project-archive material; no review needed.
- The skill was run in the last 3 months on a related project (defer until enough new material has accumulated).

## What it does

1. **Reads** `docs/wiki/lessons.md` (in current repo). If not present, surface that and exit.

2. **Classifies** every entry by `Generalizable?` field:
   - `no` → archive with project, no further action.
   - `maybe` / `yes` → candidate for promotion review.

3. **For each candidate**, presents to the user:
   - The original incident (date, title, triggered-by, cost, root cause).
   - The candidate global rule (in CLAUDE.md voice, drafted from the entry).
   - **Conflict check:** grep `~/.claude/CLAUDE.md` and `~/.claude/projects/*/memory/*.md` for existing rules covering this area. Flag any near-duplicates.
   - **Suggested tier**, with reasoning:
     - **Tier 2** (user memory `feedback_*.md`) if: cost real, concrete trigger + action, no duplicate.
     - **Tier 3** (global CLAUDE.md) only if: cost real **AND** confirmed in ≥2 separate projects **AND** "would I write this from scratch?" passes.
   - **Disqualifying check**: project-specific facts, tool-version patches, style preferences without measured cost, or "be more careful" rules → flag for `kill`.

4. **For each candidate**, asks the user to choose:
   - **promote** — apply the suggested tier as drafted.
   - **revise** — user edits the candidate rule wording before promoting.
   - **keep** — stay at current tier (lesson lives on in `lessons.md` for future review).
   - **kill** — entry doesn't actually represent a lesson worth keeping; user confirms and the entry is marked `[killed YYYY-MM-DD: not a generalizable lesson]` in `lessons.md` (entry is not deleted — kill decisions are themselves useful institutional memory).

5. **Applies decisions:**
   - **Tier 2 promotions:** draft the new `feedback_<topic>.md` file under `~/.claude/projects/<current-project-dir>/memory/`, update `MEMORY.md` index. Present for user review before saving.
   - **Tier 3 promotions:** draft the CLAUDE.md edit including which existing rule (if any) gets displaced. Check the current CLAUDE.md line count — if adding the rule would push it over the 250-line soft cap and no displacement is offered, surface that constraint to the user. Present the diff for user review before applying.

6. **Logs the review** by appending to `docs/wiki/log.md`:
   ```markdown
   ## YYYY-MM-DD — Lessons review completed
   - <N> candidates reviewed
   - <M> promoted to Tier 2 (user memory)
   - <K> promoted to Tier 3 (global CLAUDE.md)
   - <Z> killed as non-generalizable
   - <X> kept at current tier
   ```

7. **Optional HTML export** (Phase 2 of the wiki-format redesign — not yet implemented): if the user runs `/lessons-review --html`, also produce `docs/reports/lessons-review-YYYY-MM-DD.html` as a single-file shareable retrospective.

## Hard rules

- **No auto-edits.** Every promotion is user-confirmed. The skill drafts and presents; the user accepts, revises, or rejects.
- **No promotion to Tier 3 from a single project's evidence.** Tier 3 requires ≥2-project confirmation. If a lesson looks Tier-3-worthy from one project, promote to Tier 2 and flag for re-evaluation at the next project's review.
- **Annual Tier-3 budget is ≤5 new rules/year.** If this review would push the yearly count over 5, surface that to the user — they may want to defer or substitute.
- **No editing `lessons.md` destructively.** Killed entries stay in place with a `[killed YYYY-MM-DD]` marker. Promoted entries are marked `[promoted to Tier 2 → feedback_X.md]` or `[promoted to Tier 3 → CLAUDE.md §Testing]` with a link. The original wording is preserved.

## Output

A summary at the end of the run:

```
Lessons Review — <project-name>, <YYYY-MM-DD>

Candidates reviewed: <N>
  Promoted to Tier 2 (memory): <M>  →  list of new feedback_*.md files
  Promoted to Tier 3 (CLAUDE.md): <K>  →  list of CLAUDE.md sections added/edited
  Killed (not generalizable):   <Z>
  Kept at current tier:         <X>

Annual Tier-3 count: <current> of 5 budget

Logged in docs/wiki/log.md.
```

## Related

- Spec: `PROJECT_WIKI_SCHEMA.md` §6
- Rules / promotion criteria: same §6
- Capture format: `lessons.md` template
- Memory system: `~/.claude/CLAUDE.md` "auto memory" section
