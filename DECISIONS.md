# Decisions

<!-- DECISIONS.md is committed to git — it accumulates across sessions. -->
<!-- One entry per meaningful implementation decision. -->
<!-- Do not record trivial choices. Record choices that a reviewer would ask about. -->

---

## Decision Log

### --force does not override HANDOFF.md / DECISIONS.md preservation
- **Decision:** `--force` flag only affects config files (CLAUDE.md, CONVENTIONS.md, AGENTS.md, settings.json). It never overwrites HANDOFF.md or DECISIONS.md.
- **Alternatives considered:** Allow `--force` to wipe all files including session history (original behaviour before B-001 fix).
- **Rationale:** Session history is irreplaceable. A user running `upgrade --force` to refresh agent prompts should never silently lose months of handoff context. If someone genuinely needs to reset session history they can `rm` the files manually.
- **Affected files:** `rig-stage` (step 7), `tests/test_install.sh`
- **Date:** 2026-03-19

### session-start hook uses sed substitution on fresh template, not append
- **Decision:** On a fresh SCRATCHPAD.md template (detected by `<session date>` placeholder), the hook substitutes the date in-place with `sed`. On subsequent days it appends a new `# Session` block.
- **Alternatives considered:** Always append `# Session YYYY-MM-DD` at the bottom (original F-007 spec). This produced a document with two conflicting headers — unfilled placeholder at top, appended date at bottom.
- **Rationale:** Substituting the placeholder produces a clean, well-formed document. The two-pattern idempotency guard (check for date string, not header prefix) makes both paths safe.
- **Affected files:** `targets/claude-code/session-start.sh`
- **Date:** 2026-03-19

### Stop hook prints reminder, does not auto-write session files
- **Decision:** The `Stop` hook runs `session-end.sh`, which checks if HANDOFF.md has today's date and prints a checklist if not. It does not attempt to write HANDOFF.md or DECISIONS.md automatically.
- **Alternatives considered:** Auto-writing session files from the hook (impossible — the hook is a bash script with no access to conversation context); no Stop hook at all.
- **Rationale:** Meaningful content (what was done, what decisions were made) can only come from the agent. The hook's job is to surface the gap so the agent or user notices and acts.
- **Affected files:** `targets/claude-code/session-end.sh`, `targets/claude-code/settings.json.template`
- **Date:** 2026-03-19

### DECISIONS.md heading does not include session date
- **Decision:** `# Decisions` (no date). Each individual entry has its own `**Date:** YYYY-MM-DD` field.
- **Alternatives considered:** `# Decisions — <session date>` (original template) — placeholder never gets substituted since DECISIONS.md is persistent and never overwritten after first install.
- **Rationale:** The file accumulates across all sessions; a single date in the heading is meaningless and stays as a broken placeholder forever.
- **Affected files:** `session/DECISIONS.md.template`, `DECISIONS.md`
- **Date:** 2026-03-19
