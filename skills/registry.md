# Skills Registry

<!-- @imported in CLAUDE.md for auto-discovery -->
<!-- payload-depot-skill-check.sh reads this to detect unregistered or missing skills -->
<!-- Format: one ## <name> block per skill. Name must match the folder path relative to skills/. -->

## tdd
**File:** tdd/SKILL.md
**Triggers:** "use TDD", "write tests first", "failing test first", before implementing any feature or bugfix
**Description:** Guide test-driven development: write failing test, implement minimum code, refactor
**Smoke test:** `Use TDD to write a function that returns the sum of two numbers`

## linting
**File:** linting/SKILL.md
**Triggers:** "lint", "run linter", "check style", before committing, after writing code
**Description:** Run and interpret linting for the detected project language
**Smoke test:** `Run linting on the current project and report any violations`

## type-checking
**File:** type-checking/SKILL.md
**Triggers:** "type check", "run mypy", "run tsc", "check types", before committing
**Description:** Run static type checker for the detected project language
**Smoke test:** `Run type checking on the current project and report any errors`

## dependency-audit
**File:** dependency-audit/SKILL.md
**Triggers:** "audit dependencies", "check for vulnerabilities", "security audit", before release
**Description:** Audit project dependencies for known security vulnerabilities
**Smoke test:** `Run a dependency audit on the current project`

## adr
**File:** adr/SKILL.md
**Triggers:** "record decision", "write an ADR", "architecture decision", "document this choice"
**Description:** Write an Architecture Decision Record for a significant design choice
**Smoke test:** `Write an ADR for the decision to use Bash as the primary scripting language`

## readme-gen
**File:** readme-gen/SKILL.md
**Triggers:** "generate README", "write README", "update README", "document the project"
**Description:** Generate or update a project README from existing code and docs
**Smoke test:** `Generate a README for the current project`

## openapi-lint
**File:** openapi-lint/SKILL.md
**Triggers:** "lint OpenAPI", "validate OpenAPI spec", "check API spec", "openapi-lint"
**Description:** Validate and lint an OpenAPI specification file
**Smoke test:** `Run openapi-lint on any OpenAPI spec file in the current project`

## changelog
**File:** changelog/SKILL.md
**Triggers:** "update changelog", "write changelog entry", "CHANGELOG", after completing a release
**Description:** Write or update a CHANGELOG following Keep a Changelog format
**Smoke test:** `Add a changelog entry for a hypothetical v1.1.0 release`

## commit-msg
**File:** commit-msg/SKILL.md
**Triggers:** "write commit message", "commit message", "conventional commit", before committing
**Description:** Write a Conventional Commits-compliant commit message for staged changes
**Smoke test:** `Write a commit message for adding a new skill check system`

## env-setup
**File:** env-setup/SKILL.md
**Triggers:** "set up environment", "env setup", "onboarding", "install dependencies", "first time setup"
**Description:** Guide environment setup for the detected project language and toolchain
**Smoke test:** `Run env setup for the current project`

## base/clean-code
**File:** base/clean-code/SKILL.md
**Triggers:** "clean code", "type safety", "remove any types", "import hygiene", "sanitization pass", during any code execution or verification phase
**Description:** Enforce zero-Any policy, import hygiene, and CSS architecture standards
**Smoke test:** `Run a sanitization pass on the current file for any types and unused imports`

## architecture/lich
**File:** architecture/lich/SKILL.md
**Triggers:** "architect", "design the system", "plan the architecture", "architecture review", at the start of any non-trivial feature
**Description:** Architecture orchestrator — runs multi-pass structured design (domain, layers, patterns, audit)
**Smoke test:** `Architect a simple REST API with user authentication`

## architecture/phylactery-lich
**File:** architecture/phylactery-lich/SKILL.md
**Triggers:** "phylactery", "skullrender architecture", "SkullRender design", SkullRender-specific architecture sessions
**Description:** SkullRender-specific architecture variant extending the Lich orchestrator
**Smoke test:** `Apply phylactery-lich architecture to design a multi-agent workflow system`

## architecture/socratic-mvp
**File:** architecture/socratic-mvp/SKILL.md
**Triggers:** "define MVP", "socratic questions", "what are we building", "scope the MVP", at the start of any MVP or domain modeling session
**Description:** Socratic dialogue methodology for MVP discovery, domain validation, and scope definition
**Smoke test:** `Use socratic-mvp to define the MVP for a task management app`

## prompt-master
**File:** prompt-master/SKILL.md
**Triggers:** "write me a prompt", "help me prompt", "optimize this prompt", "I'm getting bad results from X", "fix my prompt", "prompt for Claude/ChatGPT/Cursor/Midjourney"
**Description:** Generate a single production-ready prompt for any AI tool — optimized for the target system, zero wasted tokens, ready to paste on the first attempt
**Smoke test:** `Write me a prompt for Claude to summarize a legal contract in plain English`
