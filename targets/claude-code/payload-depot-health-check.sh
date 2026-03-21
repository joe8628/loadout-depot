#!/usr/bin/env bash
# Loadout Depot post-install health check
# Installed to .claude/hooks/payload-depot-health-check.sh by payload-depot.
#
# Runs automatically on the first session prompt after install/upgrade
# (when .payload-depot-verified is absent). On full pass, writes .payload-depot-verified
# so future session starts skip this check.
#
# Run manually at any time: bash .claude/hooks/payload-depot-health-check.sh

set -uo pipefail

MARKER=".payload-depot-verified"
PASS=0
FAIL=0

ok()   { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

check_file() {
  local desc="$1" path="$2"
  if [[ -f "$path" ]]; then ok "$desc"; else fail "$desc — $path not found"; fi
}

check_dir() {
  local desc="$1" path="$2"
  if [[ -d "$path" ]]; then ok "$desc"; else fail "$desc — $path not found"; fi
}

check_exec() {
  local desc="$1" path="$2"
  if [[ -x "$path" ]]; then ok "$desc"; else fail "$desc — $path not executable"; fi
}

check_contains() {
  local desc="$1" path="$2" needle="$3"
  if grep -qF "$needle" "$path" 2>/dev/null; then
    ok "$desc"
  else
    fail "$desc — '$needle' not found in $path"
  fi
}

check_not_contains() {
  local desc="$1" path="$2" needle="$3"
  if grep -qF "$needle" "$path" 2>/dev/null; then
    fail "$desc — '$needle' still present in $path"
  else
    ok "$desc"
  fi
}

echo "[payload-depot] Running post-install health check..."
echo ""

# ── File existence ─────────────────────────────────────────────────────────────
echo "-- files --"
check_file "CLAUDE.md"                    "CLAUDE.md"
check_file "CONVENTIONS.md"               "CONVENTIONS.md"
check_file "AGENTS.md"                    "AGENTS.md"
check_file "settings.json"                ".claude/settings.json"
check_file "HANDOFF.md"                   "HANDOFF.md"
check_file "DECISIONS.md"                 "DECISIONS.md"
check_dir  "agents dir"                   ".claude/agents"
check_dir  "skills dir"                   ".claude/skills"
check_file "session-start.sh"             ".claude/hooks/session-start.sh"
check_file "session-end.sh"               ".claude/hooks/session-end.sh"
check_file "payload-depot-health-check.sh"          ".claude/hooks/payload-depot-health-check.sh"
check_file "payload-depot-skill-check.sh"           ".claude/hooks/payload-depot-skill-check.sh"
check_file "skills registry"              ".claude/skills/registry.md"
check_file "pre-commit hook"              ".git/hooks/pre-commit"

# ── Executability ──────────────────────────────────────────────────────────────
echo ""
echo "-- permissions --"
check_exec "session-start.sh executable"  ".claude/hooks/session-start.sh"
check_exec "session-end.sh executable"   ".claude/hooks/session-end.sh"
check_exec "payload-depot-skill-check.sh executable" ".claude/hooks/payload-depot-skill-check.sh"
check_exec "pre-commit executable"       ".git/hooks/pre-commit"

# ── CLAUDE.md content ──────────────────────────────────────────────────────────
echo ""
echo "-- CLAUDE.md --"
check_contains     "@.codebase-context/repo_map.md"  "CLAUDE.md"  "@.codebase-context/repo_map.md"
check_contains     "@HANDOFF.md import"               "CLAUDE.md"  "@HANDOFF.md"
check_contains     "@CONVENTIONS.md import"           "CLAUDE.md"  "@CONVENTIONS.md"
check_contains     "@AGENTS.md import"                "CLAUDE.md"  "@AGENTS.md"
check_not_contains "<Project Name> substituted"       "CLAUDE.md"  "<Project Name>"
check_not_contains "<language> substituted"           "CLAUDE.md"  "<language and primary tools>"

# ── settings.json content ──────────────────────────────────────────────────────
echo ""
echo "-- settings.json --"
check_contains "mcpServers configured"   ".claude/settings.json"  "mcpServers"
check_contains "UserPromptSubmit hook"   ".claude/settings.json"  "UserPromptSubmit"
check_contains "Stop hook"               ".claude/settings.json"  "Stop"
check_contains "session-start.sh wired" ".claude/settings.json"  "session-start.sh"
check_contains "session-end.sh wired"   ".claude/settings.json"  "session-end.sh"

# ── .gitignore entries ─────────────────────────────────────────────────────────
echo ""
echo "-- .gitignore --"
check_contains "SCRATCHPAD.md gitignored"  ".gitignore"  "SCRATCHPAD.md"
check_contains ".payload-depot-verified gitignored"  ".gitignore"  ".payload-depot-verified"

# ── Agent count ────────────────────────────────────────────────────────────────
echo ""
echo "-- agents / skills --"
agent_count=$(find .claude/agents -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$agent_count" -ge 9 ]]; then
  ok "agents installed ($agent_count)"
else
  fail "agents: expected >=9, got $agent_count"
fi

# ── Skill check (delegates to payload-depot-skill-check.sh) ──────────────────────────────
if bash ".claude/hooks/payload-depot-skill-check.sh" > /dev/null 2>&1; then
  ok "skills valid (payload-depot-skill-check passed)"
else
  fail "skills: payload-depot-skill-check.sh failed — run: bash .claude/hooks/payload-depot-skill-check.sh"
fi

# ── Session hook behaviour ─────────────────────────────────────────────────────
echo ""
echo "-- session hooks --"
today=$(date +%Y-%m-%d)
export PAYLOAD_DEPOT_HEALTH_CHECK_ACTIVE=1
bash ".claude/hooks/session-start.sh" 2>/dev/null || true
if grep -qF "$today" SCRATCHPAD.md 2>/dev/null; then
  ok "session-start writes today's date to SCRATCHPAD.md"
else
  fail "session-start did not write today's date to SCRATCHPAD.md"
fi

# ── Result ─────────────────────────────────────────────────────────────────────
echo ""
echo "[payload-depot] Health check: $PASS passed, $FAIL failed"

if [[ $FAIL -eq 0 ]]; then
  printf "PAYLOAD_DEPOT_VERIFIED=true\nTIMESTAMP=%s\nCHECKS=%d passed\n" \
    "$(date +%Y-%m-%dT%H:%M:%S)" "$PASS" > "$MARKER"
  echo "[payload-depot] ✓ All checks passed — .payload-depot-verified written (skipped on future session starts)"
  echo "[payload-depot]   To re-run: rm .payload-depot-verified && bash .claude/hooks/payload-depot-health-check.sh"
else
  echo "[payload-depot] ✗ $FAIL check(s) failed — fix then re-run: bash .claude/hooks/payload-depot-health-check.sh"
  echo "[payload-depot]   Or reinstall: payload-depot install --force"
  exit 1
fi
