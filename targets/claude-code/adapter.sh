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
  mkdir -p ".claude"
}

adapter_post_install() {
  : # no-op for v1.0
}
