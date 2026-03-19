# Skills Registry

<!-- @imported in CLAUDE.md for auto-discovery -->
<!-- rig-skill-check.sh reads this to detect unregistered or missing skills -->
<!-- Format: one ## <name> block per skill. Name must match the .md filename exactly. -->

## tdd
**File:** tdd.md
**Triggers:** "use TDD", "write tests first", "failing test first", before implementing any feature or bugfix
**Description:** Guide test-driven development: write failing test, implement minimum code, refactor
**Smoke test:** `Use TDD to write a function that returns the sum of two numbers`

## linting
**File:** linting.md
**Triggers:** "lint", "run linter", "check style", before committing, after writing code
**Description:** Run and interpret linting for the detected project language
**Smoke test:** `Run linting on the current project and report any violations`

## type-checking
**File:** type-checking.md
**Triggers:** "type check", "run mypy", "run tsc", "check types", before committing
**Description:** Run static type checker for the detected project language
**Smoke test:** `Run type checking on the current project and report any errors`

## dependency-audit
**File:** dependency-audit.md
**Triggers:** "audit dependencies", "check for vulnerabilities", "security audit", before release
**Description:** Audit project dependencies for known security vulnerabilities
**Smoke test:** `Run a dependency audit on the current project`

## adr
**File:** adr.md
**Triggers:** "record decision", "write an ADR", "architecture decision", "document this choice"
**Description:** Write an Architecture Decision Record for a significant design choice
**Smoke test:** `Write an ADR for the decision to use Bash as the primary scripting language`

## readme-gen
**File:** readme-gen.md
**Triggers:** "generate README", "write README", "update README", "document the project"
**Description:** Generate or update a project README from existing code and docs
**Smoke test:** `Generate a README for the current project`

## openapi-lint
**File:** openapi-lint.md
**Triggers:** "lint OpenAPI", "validate OpenAPI spec", "check API spec", "openapi-lint"
**Description:** Validate and lint an OpenAPI specification file
**Smoke test:** `Run openapi-lint on any OpenAPI spec file in the current project`

## changelog
**File:** changelog.md
**Triggers:** "update changelog", "write changelog entry", "CHANGELOG", after completing a release
**Description:** Write or update a CHANGELOG following Keep a Changelog format
**Smoke test:** `Add a changelog entry for a hypothetical v1.1.0 release`

## commit-msg
**File:** commit-msg.md
**Triggers:** "write commit message", "commit message", "conventional commit", before committing
**Description:** Write a Conventional Commits-compliant commit message for staged changes
**Smoke test:** `Write a commit message for adding a new skill check system`

## env-setup
**File:** env-setup.md
**Triggers:** "set up environment", "env setup", "onboarding", "install dependencies", "first time setup"
**Description:** Guide environment setup for the detected project language and toolchain
**Smoke test:** `Run env setup for the current project`
