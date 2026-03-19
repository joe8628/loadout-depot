#!/usr/bin/env bash
# rig-skill-check.sh — Three-layer skill validation
# Installed to .claude/hooks/rig-skill-check.sh by adapter_post_install.
# Run from the project root. Called by rig-health-check.sh.
# Run manually: bash .claude/hooks/rig-skill-check.sh
set -uo pipefail

PASS=0
FAIL=0
WARN=0

ok()   { echo "  ✓ $1"; PASS=$((PASS+1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL+1)); }
warn() { echo "  ~ $1"; WARN=$((WARN+1)); }

SKILLS_DIR=".claude/skills"
REGISTRY="$SKILLS_DIR/registry.md"

echo "[rig:skill-check] Checking skills in $SKILLS_DIR..."
echo ""

# ── Layer 1: Presence check ───────────────────────────────────────────────────
echo "-- presence --"

if [[ ! -f "$REGISTRY" ]]; then
  fail "registry.md not found at $REGISTRY"
  echo ""
  echo "[rig:skill-check] $PASS passed, $WARN warnings, $FAIL failed"
  exit 1
fi

# Extract registered skill names (## <name> headings)
registered=()
while IFS= read -r line; do
  name="${line#\#\# }"
  registered+=("$name")
done < <(grep "^## " "$REGISTRY")

# Extract installed skill names (folders containing SKILL.md, relative to SKILLS_DIR)
installed=()
while IFS= read -r skill_file; do
  rel="${skill_file#$SKILLS_DIR/}"
  rel_dir="$(dirname "$rel")"
  installed+=("$rel_dir")
done < <(find "$SKILLS_DIR" -name "SKILL.md" 2>/dev/null | sort)

# Installed but not registered → warning (not a hard failure)
for skill in "${installed[@]+"${installed[@]}"}"; do
  found=false
  for reg in "${registered[@]+"${registered[@]}"}"; do
    [[ "$reg" == "$skill" ]] && found=true && break
  done
  if $found; then
    ok "$skill registered"
  else
    warn "$skill not in registry — add it to $REGISTRY"
  fi
done

# Registered but missing from disk → fail
for skill in "${registered[@]+"${registered[@]}"}"; do
  if [[ ! -f "$SKILLS_DIR/$skill/SKILL.md" ]]; then
    fail "$skill registered but $SKILLS_DIR/$skill/SKILL.md not found"
  fi
done

# ── Layer 2: Structural check ─────────────────────────────────────────────────
echo ""
echo "-- structure --"

for skill in "${registered[@]+"${registered[@]}"}"; do
  file="$SKILLS_DIR/$skill/SKILL.md"
  [[ -f "$file" ]] || continue

  if [[ ! -s "$file" ]]; then
    fail "$skill/SKILL.md is empty"
    continue
  fi

  if ! head -1 "$file" | grep -qF -- "---"; then
    fail "$skill/SKILL.md missing frontmatter block"
    continue
  fi

  skill_fail=false

  # Accept either old-style (version/updated) or new-style (name) frontmatter
  has_version=false
  has_name=false
  grep -qF "version:" "$file" && has_version=true
  grep -qF "name:" "$file" && has_name=true

  if ! $has_version && ! $has_name; then
    fail "$skill/SKILL.md frontmatter missing 'name' or 'version' field"
    skill_fail=true
  fi

  $skill_fail || ok "$skill/SKILL.md valid"
done

# ── Layer 3: Readability check ────────────────────────────────────────────────
echo ""
echo "-- readability --"

for skill in "${registered[@]+"${registered[@]}"}"; do
  file="$SKILLS_DIR/$skill/SKILL.md"
  [[ -f "$file" ]] || continue

  if [[ ! -s "$file" ]]; then
    fail "$skill/SKILL.md is empty"
    continue
  fi

  if command -v file &>/dev/null; then
    if file "$file" | grep -qE "(UTF-8|ASCII|text)"; then
      ok "$skill/SKILL.md readable"
    else
      fail "$skill/SKILL.md is not valid UTF-8 text"
    fi
  else
    ok "$skill/SKILL.md readable (file command unavailable, skipped encoding check)"
  fi
done

# ── Result ────────────────────────────────────────────────────────────────────
echo ""
echo "[rig:skill-check] $PASS passed, $WARN warnings, $FAIL failed"

if [[ $FAIL -gt 0 ]]; then
  echo "[rig:skill-check] ✗ Fix failures then re-run: bash .claude/hooks/rig-skill-check.sh"
  exit 1
fi

echo "[rig:skill-check] ✓ All checks passed"
