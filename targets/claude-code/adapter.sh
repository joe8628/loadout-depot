#!/usr/bin/env bash
# Claude Code target adapter
# Sourced by `rig install` — do not execute directly.

ADAPTER_NAME="claude-code"
AGENT_INSTALL_PATH=".claude/agents"
SKILL_INSTALL_PATH=".claude/skills"

CONFIG_FILES=(
  "CLAUDE.md.template:CLAUDE.md"
  "CONVENTIONS.md.template:CONVENTIONS.md"
  "AGENTS.md.template:AGENTS.md"
  "settings.json.template:.claude/settings.json"
)

adapter_validate() {
  command -v claude &>/dev/null
}

adapter_pre_install() {
  mkdir -p ".claude/hooks"
}

adapter_post_install() {
  cp "$PAYLOAD_DEPOT_DIR/targets/claude-code/session-start.sh"    ".claude/hooks/session-start.sh"
  chmod +x ".claude/hooks/session-start.sh"
  cp "$PAYLOAD_DEPOT_DIR/targets/claude-code/session-end.sh"      ".claude/hooks/session-end.sh"
  chmod +x ".claude/hooks/session-end.sh"
  cp "$PAYLOAD_DEPOT_DIR/targets/claude-code/payload-depot-health-check.sh" ".claude/hooks/payload-depot-health-check.sh"
  chmod +x ".claude/hooks/payload-depot-health-check.sh"
  cp "$PAYLOAD_DEPOT_DIR/targets/claude-code/payload-depot-skill-check.sh"  ".claude/hooks/payload-depot-skill-check.sh"
  chmod +x ".claude/hooks/payload-depot-skill-check.sh"
  # Clear the verified marker so the health check runs on the next session start
  rm -f ".payload-depot-verified"
}
