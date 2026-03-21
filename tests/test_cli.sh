#!/usr/bin/env bash
set -euo pipefail

PAYLOAD_DEPOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PAYLOAD_DEPOT_DIR/tests/lib.sh"

echo "=== CLI Tests ==="

echo ""
echo "-- payload-depot version --"
output=$("$PAYLOAD_DEPOT_DIR/payload-depot" version 2>&1) || true
assert_contains "version outputs version string" "1.0.0" "$output"

echo ""
echo "-- payload-depot help --"
output=$("$PAYLOAD_DEPOT_DIR/payload-depot" help 2>&1) || true
assert_contains "help mentions install" "install" "$output"
assert_contains "help mentions list" "list" "$output"

echo ""
echo "-- payload-depot unknown command --"
code=0; "$PAYLOAD_DEPOT_DIR/payload-depot" unknown-cmd 2>/dev/null || code=$?
assert_exit_code "unknown command exits 1" "1" "$code"

echo ""
echo "-- payload-depot install unknown target --"
tmp=$(mktemp -d) && git -C "$tmp" init -q
code=0; (cd "$tmp" && "$PAYLOAD_DEPOT_DIR/payload-depot" install --target nonexistent 2>/dev/null) || code=$?
assert_exit_code "unknown target exits 3" "3" "$code"
rm -rf "$tmp"

echo ""
echo "-- payload-depot install no git repo --"
tmp=$(mktemp -d)
code=0; (cd "$tmp" && "$PAYLOAD_DEPOT_DIR/payload-depot" install 2>/dev/null) || code=$?
assert_exit_code "no git repo exits 2" "2" "$code"
rm -rf "$tmp"

echo ""
echo "-- adapter exports --"
# shellcheck source=/dev/null
source "$PAYLOAD_DEPOT_DIR/targets/claude-code/adapter.sh" 2>/dev/null || true
assert_eq "ADAPTER_NAME is claude-code" "claude-code" "${ADAPTER_NAME:-}"
assert_eq "AGENT_INSTALL_PATH is .claude/agents" ".claude/agents" "${AGENT_INSTALL_PATH:-}"
assert_eq "SKILL_INSTALL_PATH is .claude/skills" ".claude/skills" "${SKILL_INSTALL_PATH:-}"

report
