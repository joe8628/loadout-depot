Diagnose the current bug or test failure systematically — do not guess or try random fixes:

1. **Capture the failure**
   - Run the failing command and collect full output (exit code, stdout, stderr)
   - If a test: identify the exact test name and file

2. **Locate the blast radius**
   - Which files or functions are in the execution path?
   - When did this last work? Run `git log --oneline -10` and identify the introducing commit

3. **Form a hypothesis**
   - State one specific cause in plain English before touching any code
   - If multiple hypotheses exist, rank them by likelihood

4. **Verify the hypothesis**
   - Add a targeted diagnostic (log, assertion, or minimal reproduction) to confirm
   - Do NOT write a fix until the root cause is confirmed

5. **Fix and verify**
   - Make the minimal change that addresses the root cause
   - Re-run the full test suite to confirm no regressions (see Commands section in CLAUDE.md)

6. **Report**
   - Root cause (one sentence)
   - Fix applied
   - Tests now passing
