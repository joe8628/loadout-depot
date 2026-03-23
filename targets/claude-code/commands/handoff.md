Complete the post-feature handoff ritual for the current task:

1. Read HANDOFF.md to find the most recent block and confirm the task is actually done
2. Append a completion note to SCRATCHPAD.md with today's date and a one-line summary
3. Append a new block to HANDOFF.md using the standard template:
   - Agent: Claude Sonnet 4.6
   - Completed: today's date
   - Task: what was just built or fixed
   - Output Files: every file created or meaningfully changed
   - Assumptions Made: any non-obvious choices made during implementation
   - What Was Not Done: deferred work or known gaps
   - Uncertainties: open questions or risks
   - Instructions for Next Agent: what to run first, what to tackle next
4. If any non-trivial decisions were made, append them to DECISIONS.md
5. Stage and commit: `git add HANDOFF.md DECISIONS.md && git commit -m "handoff: Claude Sonnet 4.6 completed <task>"`
6. Push: `git push`

Do not abbreviate or skip any section of the HANDOFF block — future agents depend on complete context.
