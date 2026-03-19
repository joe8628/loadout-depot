# Handoff Log

<!-- HANDOFF.md is committed to git. -->
<!-- Session start: run `git pull` before reading this file. -->
<!-- Session end: `git add HANDOFF.md DECISIONS.md && git commit -m "handoff: <agent> completed <task>" && git push` -->
<!-- Each agent appends one block when it completes its task. Do not edit previous blocks. -->

---

## Block Template (copy and fill per agent)

### Agent: <agent name>
**Completed:** <timestamp>
**Task:** <what was asked>

#### Output Files
<!-- List every file written or modified, with a one-line description of what changed. -->

#### Assumptions Made
<!-- List any assumptions that are not stated in the task brief. -->

#### What Was Not Done
<!-- Explicitly state what was out of scope or deferred, and why. -->

#### Uncertainties
<!-- Flag anything the next agent should verify before relying on. -->

#### Instructions for Next Agent
<!-- Direct instructions. What should the next agent read first, do first, watch out for. -->

---

### Agent: code-writer (Claude Sonnet 4.6)
**Completed:** 2026-03-19
**Task:** Implement B-001, F-006, F-007 — session file preservation, @file imports, session hooks

#### Output Files
- `rig-stage` — step 7 rewritten: SCRATCHPAD.md always overwrites, HANDOFF.md + DECISIONS.md skip-if-exists (even under --force)
- `targets/claude-code/CLAUDE.md.template` — added `@HANDOFF.md`, `@CONVENTIONS.md`, `@AGENTS.md` imports after repo map line
- `targets/claude-code/settings.json.template` — added `UserPromptSubmit` and `Stop` hooks
- `targets/claude-code/session-start.sh` — new: git pull + dated SCRATCHPAD header (idempotent, sed-substitutes fresh template)
- `targets/claude-code/session-end.sh` — new: Stop hook reminder to write HANDOFF.md/DECISIONS.md if not yet updated today
- `targets/claude-code/adapter.sh` — pre_install creates `.claude/hooks/`; post_install copies + chmods both hook scripts
- `session/DECISIONS.md.template` — removed `<session date>` from heading (file accumulates across all sessions)
- `DECISIONS.md` — same fix applied to live repo file
- `tests/test_install.sh` — 16 new tests covering B-001, F-006, F-007 (46 total, all passing)
- `FEATURES.md` — F-008 (OpenAPI) replaced with F-008–F-016 (OpenSpec skill suite)

#### Assumptions Made
- `--force` should NEVER wipe HANDOFF.md or DECISIONS.md — confirmed with user, treated as invariant
- Claude Code silently ignores missing `@file` references — no guard needed for fresh installs
- `Stop` hook output is shown to the user in the terminal (not injected back to Claude)

#### What Was Not Done
- F-001 (CLAUDE.md placeholder substitution) — deferred, next in priority after this session
- OpenSpec skills (F-008–F-016) — features documented but not implemented
- `--force` does not reset HANDOFF.md/DECISIONS.md even when explicitly requested — this is intentional but not yet documented in the spec

#### Uncertainties
- Verify that `Stop` hook output actually appears in the Claude Code UI — behaviour depends on Claude Code version
- `git pull --ff-only` will silently fail in repos with no remote; this is intentional (`|| true`) but worth monitoring

#### Instructions for Next Agent
- Read FEATURES.md — start with F-001 (auto-populate CLAUDE.md placeholders), then F-002/F-003
- All 46 tests in `tests/test_install.sh` must continue to pass after any changes to `rig-stage` or adapter files
- The B-001 fix (HANDOFF.md/DECISIONS.md preservation) is now an invariant — do not regress it
- Commit F-006/F-007 work before starting F-001 (user approved, pending commit)
