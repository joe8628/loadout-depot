#!/usr/bin/env bash
set -uo pipefail

RIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$RIG_DIR/tests/lib.sh"

SKILL_CHECK="$RIG_DIR/targets/claude-code/rig-skill-check.sh"

# ── Helpers ───────────────────────────────────────────────────────────────────

setup_skill_env() {
  local tmp
  tmp=$(mktemp -d)
  mkdir -p "$tmp/.claude/skills"
  echo "$tmp"
}

make_valid_skill() {
  local dir="$1" name="$2"
  mkdir -p "$dir/.claude/skills/$name"
  cat > "$dir/.claude/skills/$name/SKILL.md" <<'SKILL'
---
version: 1.0.0
updated: 2026-03-01
---

# test-skill

## Purpose
Test purpose.

## Trigger
Test trigger.

## Process
Test process.
SKILL
}

make_valid_skill_new_format() {
  local dir="$1" name="$2"
  mkdir -p "$dir/.claude/skills/$name"
  cat > "$dir/.claude/skills/$name/SKILL.md" <<'SKILL'
---
name: test-skill
category: testing
---

# test-skill

Test skill content.
SKILL
}

make_registry_entry() {
  local dir="$1" name="$2"
  cat >> "$dir/.claude/skills/registry.md" <<REG

## $name
**File:** $name/SKILL.md
**Triggers:** test trigger
**Description:** Test skill
**Smoke test:** \`Test the skill\`
REG
}

init_registry() {
  local dir="$1"
  echo "# Skills Registry" > "$dir/.claude/skills/registry.md"
}

run_check() {
  local dir="$1"
  (cd "$dir" && bash "$SKILL_CHECK" 2>&1)
}

echo "=== Skill Check Tests ==="

# ── 1. no-registry ────────────────────────────────────────────────────────────
echo ""
echo "-- no-registry --"
dir=$(setup_skill_env)
exit_code=0; output=$(run_check "$dir" 2>&1) || exit_code=$?
assert_exit_code "no registry exits 1"       "1" "$exit_code"
assert_contains  "no registry prints error"  "registry.md not found" "$output"
rm -rf "$dir"

# ── 2. all-valid ──────────────────────────────────────────────────────────────
echo ""
echo "-- all-valid --"
dir=$(setup_skill_env)
init_registry "$dir"
make_valid_skill "$dir" "tdd"
make_registry_entry "$dir" "tdd"
exit_code=0; run_check "$dir" > /dev/null 2>&1 || exit_code=$?
assert_exit_code "all valid exits 0" "0" "$exit_code"
rm -rf "$dir"

# ── 3. all-valid new-format frontmatter ───────────────────────────────────────
echo ""
echo "-- all-valid-new-format --"
dir=$(setup_skill_env)
init_registry "$dir"
make_valid_skill_new_format "$dir" "clean-code"
make_registry_entry "$dir" "clean-code"
exit_code=0; run_check "$dir" > /dev/null 2>&1 || exit_code=$?
assert_exit_code "new-format skill exits 0" "0" "$exit_code"
rm -rf "$dir"

# ── 4. unregistered-skill (warn only, exit 0) ─────────────────────────────────
echo ""
echo "-- unregistered-skill --"
dir=$(setup_skill_env)
init_registry "$dir"
make_valid_skill "$dir" "tdd"
# tdd/SKILL.md exists but registry is empty — should warn, not fail
exit_code=0; output=$(run_check "$dir" 2>&1) || exit_code=$?
assert_exit_code "unregistered exits 0 (warn)" "0" "$exit_code"
assert_contains  "unregistered prints warning"  "not in registry" "$output"
rm -rf "$dir"

# ── 5. missing-skill (registered but folder absent) ───────────────────────────
echo ""
echo "-- missing-skill --"
dir=$(setup_skill_env)
init_registry "$dir"
make_registry_entry "$dir" "tdd"
# tdd/SKILL.md NOT created
exit_code=0; output=$(run_check "$dir" 2>&1) || exit_code=$?
assert_exit_code "missing skill exits 1"     "1" "$exit_code"
assert_contains  "missing skill prints fail" "registered but" "$output"
rm -rf "$dir"

# ── 6. missing-frontmatter ────────────────────────────────────────────────────
echo ""
echo "-- missing-frontmatter --"
dir=$(setup_skill_env)
init_registry "$dir"
make_registry_entry "$dir" "tdd"
mkdir -p "$dir/.claude/skills/tdd"
printf '# tdd\n\nSome content without frontmatter.\n' \
  > "$dir/.claude/skills/tdd/SKILL.md"
exit_code=0; output=$(run_check "$dir" 2>&1) || exit_code=$?
assert_exit_code "missing frontmatter exits 1"    "1" "$exit_code"
assert_contains  "missing frontmatter prints fail" "missing frontmatter" "$output"
rm -rf "$dir"

# ── 7. missing-name-and-version ───────────────────────────────────────────────
echo ""
echo "-- missing-name-and-version --"
dir=$(setup_skill_env)
init_registry "$dir"
make_registry_entry "$dir" "tdd"
mkdir -p "$dir/.claude/skills/tdd"
cat > "$dir/.claude/skills/tdd/SKILL.md" <<'SKILL'
---
updated: 2026-03-01
---

# tdd

Some content.
SKILL
exit_code=0; output=$(run_check "$dir" 2>&1) || exit_code=$?
assert_exit_code "missing name/version exits 1"    "1" "$exit_code"
assert_contains  "missing name/version prints fail" "missing 'name' or 'version'" "$output"
rm -rf "$dir"

# ── 8. empty-skill-file ───────────────────────────────────────────────────────
echo ""
echo "-- empty-skill-file --"
dir=$(setup_skill_env)
init_registry "$dir"
make_registry_entry "$dir" "tdd"
mkdir -p "$dir/.claude/skills/tdd"
touch "$dir/.claude/skills/tdd/SKILL.md"
exit_code=0; output=$(run_check "$dir" 2>&1) || exit_code=$?
assert_exit_code "empty skill exits 1"    "1" "$exit_code"
assert_contains  "empty skill prints fail" "is empty" "$output"
rm -rf "$dir"

# ── 9. registry-excluded ──────────────────────────────────────────────────────
echo ""
echo "-- registry-excluded --"
dir=$(setup_skill_env)
init_registry "$dir"
make_valid_skill "$dir" "tdd"
make_registry_entry "$dir" "tdd"
# registry.md has no skill structure — must NOT be validated as a skill
exit_code=0; output=$(run_check "$dir" 2>&1) || exit_code=$?
assert_exit_code    "registry excluded exits 0"   "0" "$exit_code"
assert_not_contains "registry not validated"      "registry.md missing" "$output"
rm -rf "$dir"

# ── 10. nested-skill (architecture/lich) ──────────────────────────────────────
echo ""
echo "-- nested-skill --"
dir=$(setup_skill_env)
init_registry "$dir"
# Register with slash path
cat >> "$dir/.claude/skills/registry.md" <<'REG'

## architecture/lich
**File:** architecture/lich/SKILL.md
**Triggers:** architect
**Description:** Architecture orchestrator
**Smoke test:** `Architect a REST API`
REG
mkdir -p "$dir/.claude/skills/architecture/lich"
cat > "$dir/.claude/skills/architecture/lich/SKILL.md" <<'SKILL'
---
name: lich
category: architecture
---

# Architecture Orchestrator

Some content.
SKILL
exit_code=0; run_check "$dir" > /dev/null 2>&1 || exit_code=$?
assert_exit_code "nested skill exits 0" "0" "$exit_code"
rm -rf "$dir"

report
