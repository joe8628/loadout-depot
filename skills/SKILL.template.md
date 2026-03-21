---
version: 1.0.0
updated: YYYY-MM-DD
changelog:
  - 1.0.0: initial version
skill_type: technique | standard | architecture | methodology
hierarchy_level: 3
parent_skills: []
uses_skills: []
---

# skill-name

## Purpose

One-sentence description of what this skill does and what it produces.

## Trigger

- Specific condition or user request that activates this skill
- Invoked by <agent-name> when <condition>
- Explicit user request: "<example phrase>"

## Language Support

- **Language:** tool or command (`command here`)
- **Language:** tool or command (`command here`)

Or: Language-agnostic. Operates on <what>.

## Process

1. Step one.
2. Step two.
3. Step three.

## Output Format

Description of what the output looks like, with an example block if applicable.

```
[skill-name] Example output line
  detail: value
Verdict: clean | needs fixes
```

## Error Handling

- Condition: action to take
- Condition: action to take

---

# Frontmatter Reference

## skill_type
- `technique`    — concrete procedural method with steps to follow (tdd, linting, commit-msg)
- `standard`     — rules and constraints enforced on all code (clean-code)
- `architecture` — system design orchestrator producing architectural deliverables
- `methodology`  — structured dialogue or discovery process

## hierarchy_level
Priority in contradiction resolution. Lower number wins.
- `1` — project-specific (highest priority, overrides all)
- `2` — domain orchestrator (overrides base skills)
- `3` — universal base (applies everywhere, lowest priority)

## parent_skills
List of skill folder paths this skill extends or inherits from.
Child links are derived from parent_skills — do not maintain child lists manually.
Example:
  parent_skills:
    - architecture/lich

## uses_skills
List of skill folder paths this skill invokes or depends on at runtime (not inheritance).
Warn if referenced skill is missing. Does not imply priority override.
Example:
  uses_skills:
    - adr
    - tdd
