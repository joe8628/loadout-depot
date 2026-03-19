#!/usr/bin/env bash
set -uo pipefail

RIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$RIG_DIR/tests/lib.sh"

# Copy a fixture into a temp dir with a fresh .git so tests are isolated
setup_fixture() {
  local fixture="$1"
  local tmp
  tmp=$(mktemp -d)
  cp -r "$RIG_DIR/tests/fixtures/$fixture/." "$tmp/"
  git -C "$tmp" init -q 2>/dev/null
  echo "$tmp"
}

cleanup() { rm -rf "$1"; }

echo "=== Install Tests ==="

# 1. fresh-install-python
echo ""
echo "-- fresh-install-python --"
dir=$(setup_fixture python-project)
(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
assert_dir_exists  "agents dir created"           "$dir/.claude/agents"
assert_dir_exists  "skills dir created"           "$dir/.claude/skills"
assert_file_exists "CLAUDE.md written"            "$dir/CLAUDE.md"
assert_file_exists "CONVENTIONS.md written"       "$dir/CONVENTIONS.md"
assert_file_exists "AGENTS.md written"            "$dir/AGENTS.md"
assert_file_exists "settings.json written"        "$dir/.claude/settings.json"
assert_file_exists "HANDOFF.md written"           "$dir/HANDOFF.md"
assert_file_exists "SCRATCHPAD.md written"        "$dir/SCRATCHPAD.md"
assert_file_exists "DECISIONS.md written"         "$dir/DECISIONS.md"
assert_file_exists "pre-commit hook installed"    "$dir/.git/hooks/pre-commit"
cleanup "$dir"

# 2. fresh-install-typescript
echo ""
echo "-- fresh-install-typescript --"
dir=$(setup_fixture typescript-project)
(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
assert_dir_exists  "agents dir created"  "$dir/.claude/agents"
assert_file_exists "CLAUDE.md written"   "$dir/CLAUDE.md"
assert_file_exists "HANDOFF.md written"  "$dir/HANDOFF.md"
cleanup "$dir"

# 3. fresh-install-cpp
echo ""
echo "-- fresh-install-cpp --"
dir=$(setup_fixture cpp-project)
(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
assert_dir_exists  "agents dir created"  "$dir/.claude/agents"
assert_file_exists "CLAUDE.md written"   "$dir/CLAUDE.md"
assert_file_exists "HANDOFF.md written"  "$dir/HANDOFF.md"
cleanup "$dir"

# 4. skip-existing-config
echo ""
echo "-- skip-existing-config --"
dir=$(setup_fixture python-project)
echo "# existing" > "$dir/CLAUDE.md"
output=$(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
assert_contains    "skip message printed"        "Skipped" "$output"
assert_eq          "CLAUDE.md not overwritten"   "# existing" "$(cat "$dir/CLAUDE.md")"
cleanup "$dir"

# 5. force-overwrite
echo ""
echo "-- force-overwrite --"
dir=$(setup_fixture python-project)
echo "# existing" > "$dir/CLAUDE.md"
(cd "$dir" && "$RIG_DIR/rig-stage" install --force --no-codebase-index 2>&1) || true
content=$(cat "$dir/CLAUDE.md")
[[ "$content" != "# existing" ]] && result=0 || result=1
assert_eq "CLAUDE.md overwritten" "0" "$result"
cleanup "$dir"

# 6. dry-run
echo ""
echo "-- dry-run --"
dir=$(setup_fixture python-project)
output=$(cd "$dir" && "$RIG_DIR/rig-stage" install --dry-run --no-codebase-index 2>&1) || true
assert_contains    "dry-run output shown"        "dry-run" "$output"
[[ ! -f "$dir/CLAUDE.md" ]] && result=0 || result=1
assert_eq          "dry-run: no files written"   "0" "$result"
cleanup "$dir"

# 7. no-git-repo
echo ""
echo "-- no-git-repo --"
dir=$(mktemp -d)
code=0; (cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>/dev/null) || code=$?
assert_exit_code "no git repo exits 2" "2" "$code"
cleanup "$dir"

# 8. unknown-target
echo ""
echo "-- unknown-target --"
dir=$(setup_fixture python-project)
code=0; (cd "$dir" && "$RIG_DIR/rig-stage" install --target nonexistent --no-codebase-index 2>/dev/null) || code=$?
assert_exit_code "unknown target exits 3" "3" "$code"
cleanup "$dir"

# 9. no-hooks
echo ""
echo "-- no-hooks --"
dir=$(setup_fixture python-project)
(cd "$dir" && "$RIG_DIR/rig-stage" install --no-hooks --no-codebase-index 2>&1) || true
[[ ! -f "$dir/.git/hooks/pre-commit" ]] && result=0 || result=1
assert_eq "hook not installed" "0" "$result"
cleanup "$dir"

# 10. no-codebase-index
echo ""
echo "-- no-codebase-index --"
dir=$(setup_fixture python-project)
output=$(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
assert_contains "skip message for index" "codebase index" "$output"
cleanup "$dir"

# 11. session-history-preserved-on-reinstall (B-001)
echo ""
echo "-- session-history-preserved-on-reinstall --"
dir=$(setup_fixture python-project)
(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
echo "# existing handoff"   > "$dir/HANDOFF.md"
echo "# existing decisions" > "$dir/DECISIONS.md"
echo "# existing scratch"   > "$dir/SCRATCHPAD.md"
(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
assert_eq "HANDOFF.md preserved"   "# existing handoff"   "$(cat "$dir/HANDOFF.md")"
assert_eq "DECISIONS.md preserved" "# existing decisions" "$(cat "$dir/DECISIONS.md")"
content=$(cat "$dir/SCRATCHPAD.md")
[[ "$content" != "# existing scratch" ]] && result=0 || result=1
assert_eq "SCRATCHPAD.md overwritten" "0" "$result"
cleanup "$dir"

# 12. session-history-preserved-with-force (B-001)
echo ""
echo "-- session-history-preserved-with-force --"
dir=$(setup_fixture python-project)
(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
echo "# existing handoff"   > "$dir/HANDOFF.md"
echo "# existing decisions" > "$dir/DECISIONS.md"
(cd "$dir" && "$RIG_DIR/rig-stage" install --force --no-codebase-index 2>&1) || true
assert_eq "HANDOFF.md preserved under --force"   "# existing handoff"   "$(cat "$dir/HANDOFF.md")"
assert_eq "DECISIONS.md preserved under --force" "# existing decisions" "$(cat "$dir/DECISIONS.md")"
cleanup "$dir"

# 13. fresh-install creates session files when absent (B-001)
echo ""
echo "-- fresh-install-creates-session-files --"
dir=$(setup_fixture python-project)
(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
assert_file_exists "HANDOFF.md created on fresh install"    "$dir/HANDOFF.md"
assert_file_exists "DECISIONS.md created on fresh install"  "$dir/DECISIONS.md"
assert_file_exists "SCRATCHPAD.md created on fresh install" "$dir/SCRATCHPAD.md"
cleanup "$dir"

# 14. F-006: CLAUDE.md contains @file imports for session files
echo ""
echo "-- claude-md-at-file-imports (F-006) --"
dir=$(setup_fixture python-project)
(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
content=$(cat "$dir/CLAUDE.md")
assert_contains "@HANDOFF.md import present"     "@HANDOFF.md"     "$content"
assert_contains "@CONVENTIONS.md import present" "@CONVENTIONS.md" "$content"
assert_contains "@AGENTS.md import present"      "@AGENTS.md"      "$content"
cleanup "$dir"

# 15. F-007: session-start and session-end hooks installed and settings.json wired
echo ""
echo "-- session-hooks (F-007) --"
dir=$(setup_fixture python-project)
(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
assert_file_exists "session-start.sh installed"  "$dir/.claude/hooks/session-start.sh"
assert_file_exists "session-end.sh installed"    "$dir/.claude/hooks/session-end.sh"
settings=$(cat "$dir/.claude/settings.json")
assert_contains "settings.json has UserPromptSubmit hook" "UserPromptSubmit"   "$settings"
assert_contains "settings.json has Stop hook"             "Stop"               "$settings"
assert_contains "settings.json references session-start"  "session-start.sh"   "$settings"
assert_contains "settings.json references session-end"    "session-end.sh"     "$settings"
cleanup "$dir"

# 16. F-007: session-start hook writes dated header to SCRATCHPAD.md
echo ""
echo "-- session-start-hook-writes-header (F-007) --"
dir=$(setup_fixture python-project)
(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
today=$(date +%Y-%m-%d)
# Run the hook directly (simulates Claude Code firing it)
(cd "$dir" && bash .claude/hooks/session-start.sh 2>/dev/null) || true
# Fresh template: hook substitutes <session date> → today in the heading
assert_contains "SCRATCHPAD.md has today's date" "$today" "$(cat "$dir/SCRATCHPAD.md")"
# Run again — must be idempotent (date appears exactly once)
(cd "$dir" && bash .claude/hooks/session-start.sh 2>/dev/null) || true
count=$(grep -cF "$today" "$dir/SCRATCHPAD.md" || true)
assert_eq "date written exactly once (idempotent)" "1" "$count"
cleanup "$dir"

# 17. F-007: hook appends new session block on a new calendar day
echo ""
echo "-- session-start-hook-new-day-append (F-007) --"
dir=$(setup_fixture python-project)
(cd "$dir" && "$RIG_DIR/rig-stage" install --no-codebase-index 2>&1) || true
today=$(date +%Y-%m-%d)
# Run hook once to fill the <session date> placeholder (normal first-run)
(cd "$dir" && bash .claude/hooks/session-start.sh 2>/dev/null) || true
# Simulate the scratchpad having been used on a previous day by replacing today's date
sed -i "s|$today|2000-01-01|g" "$dir/SCRATCHPAD.md"
# Now run hook — today's date is absent, so it should append a new session block
(cd "$dir" && bash .claude/hooks/session-start.sh 2>/dev/null) || true
assert_contains "new day block appended"  "# Session $today"    "$(cat "$dir/SCRATCHPAD.md")"
assert_contains "old day block preserved" "2000-01-01"          "$(cat "$dir/SCRATCHPAD.md")"
cleanup "$dir"

report
