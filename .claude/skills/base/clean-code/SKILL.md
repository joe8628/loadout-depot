---
version: 1.0.0
updated: 2026-03-19
changelog:
  - 1.0.0: initial version
skill_type: standard
hierarchy_level: 3
parent_skills: []
uses_skills: []
---

# clean-code

## Purpose

Enforce zero-Any policy, import hygiene, and CSS architecture standards on all code produced or modified.

## Trigger

- Any time a file is edited or an implementation task is complete
- User asks to "clean code", "sanitization pass", "remove any types", "check imports", or "type safety"
- Automatically applied during the execution and verification phases of every task

## Language Support

- **TypeScript:** `any` is forbidden; use specific interfaces, `Record<string, unknown>`, or generics
- **Python:** `Any` is forbidden; use `Dict[str, object]`, Pydantic models, or specific types
- **CSS/SCSS:** `!important` is forbidden; use CSS specificity and variables

## Process

1. Scan all created or modified files for `any` (TypeScript) or `Any` (Python) types. For each occurrence:
   - If the structure is known: replace with a specific interface, type, or Pydantic model.
   - If the structure is external or truly unknown: use `Record<string, unknown>` (TS) or `Dict[str, object]` (Python).
2. Scan all edited files for unused import statements. Remove every import that is not referenced in the file body. Be especially vigilant after parameter-type changes.
3. Scan CSS and SCSS files for `!important` declarations. Refactor each one using proper CSS specificity, scoped selectors, or CSS custom properties.
4. Prefer specific imports over wildcard imports wherever possible.

## Output Format

No file output. Inline changes only. Report a summary after the pass:

```
[clean-code] Sanitization pass complete
  Replaced Any types:      <count>
  Removed unused imports:  <count>
  Removed !important:      <count>
Verdict: clean | issues fixed
```

## Error Handling

- `Any` used for an external API response with no schema: replace with `Record<string, unknown>` (TS) or `Dict[str, object]` (Python) and add a `# TODO: type this` comment
- Removing `!important` creates a specificity conflict: refactor the rule with a more specific selector or a scoped CSS variable rather than restoring `!important`
- Import appears unused but is a side-effect import: preserve it and add a comment explaining why (e.g., `// side-effect: registers polyfill`)
