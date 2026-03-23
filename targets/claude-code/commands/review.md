Review all modified files in the current branch against project standards:

1. Run `git diff main --name-only` to identify changed files
2. For each changed file:
   - Check it follows the conventions in CONVENTIONS.md
   - Flag any hardcoded secrets, credentials, or magic values
   - Identify missing error handling at system boundaries (user input, external calls)
   - Flag dead code, unused variables, or commented-out blocks
3. Run the project test suite (see Commands section in CLAUDE.md)
4. Report results as:
   - **Blockers** — must fix before merging (security, broken tests, convention violations)
   - **Warnings** — should fix but won't block (style, minor issues)
   - **Suggestions** — optional improvements
