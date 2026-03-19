# Skill Smoke Test

Run this prompt inside Claude Code to functionally verify all registered skills.

---

## Instructions for Claude

You are about to run a smoke test for all skills registered in `.claude/skills/registry.md`.

**Steps:**

1. Read `.claude/skills/registry.md` and extract:
   - Each skill name (lines starting with `## `)
   - Its smoke test prompt (lines starting with `**Smoke test:**`)

2. For each registered skill, in order:
   a. Invoke it using the `Skill` tool: `Skill(skill="<name>")`
   b. If the Skill tool returns content → mark as **Loaded: ✓**
   b. If the Skill tool returns an error or empty response → mark as **Loaded: ✗**
   c. Execute the smoke test prompt for that skill (abbreviated — just enough to confirm the skill runs without tool errors)
   d. If execution completes without tool errors → mark as **Executed: ✓**
   d. If a tool call fails → mark as **Executed: ✗** and capture the error

3. Print a summary table:

```
| Skill            | Loaded | Executed | Status |
|------------------|--------|----------|--------|
| tdd              | ✓      | ✓        | PASS   |
| linting          | ✓      | ✓        | PASS   |
| type-checking    | ✗      | —        | FAIL   |
```

4. For each FAIL row, print the error message from the Skill tool or execution.

5. Print final counts: `X passed, Y failed`

**Notes:**
- Run smoke tests in minimal mode — the goal is load and invocation verification, not full output quality
- If a skill's smoke test would modify files, describe what it *would* do instead of doing it
- This prompt is safe to run at any time; it does not commit, push, or write files
