#!/usr/bin/env bash
# payload-depot-skill-check.sh — Three-layer skill validation
# Installed to .claude/hooks/payload-depot-skill-check.sh by adapter_post_install.
# Run from the project root. Called by payload-depot-health-check.sh.
# Run manually: bash .claude/hooks/payload-depot-skill-check.sh
set -uo pipefail

PASS=0
FAIL=0
WARN=0

ok()   { echo "  ✓ $1"; PASS=$((PASS+1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL+1)); }
warn() { echo "  ~ $1"; WARN=$((WARN+1)); }

SKILLS_DIR=".claude/skills"
REGISTRY="$SKILLS_DIR/registry.md"

echo "[payload-depot:skill-check] Checking skills in $SKILLS_DIR..."
echo ""

# ── Layer 1: Presence check ───────────────────────────────────────────────────
echo "-- presence --"

if [[ ! -f "$REGISTRY" ]]; then
  fail "registry.md not found at $REGISTRY"
  echo ""
  echo "[payload-depot:skill-check] $PASS passed, $WARN warnings, $FAIL failed"
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

  # version field (required)
  if ! grep -qF "version:" "$file"; then
    fail "$skill/SKILL.md frontmatter missing 'version' field"
    skill_fail=true
  fi

  # skill_type field (required)
  if ! grep -qF "skill_type:" "$file"; then
    fail "$skill/SKILL.md frontmatter missing 'skill_type' field"
    skill_fail=true
  fi

  # hierarchy_level field (required)
  if ! grep -qF "hierarchy_level:" "$file"; then
    fail "$skill/SKILL.md frontmatter missing 'hierarchy_level' field"
    skill_fail=true
  fi

  # parent_skills field (required)
  if ! grep -qF "parent_skills:" "$file"; then
    fail "$skill/SKILL.md frontmatter missing 'parent_skills' field"
    skill_fail=true
  fi

  # uses_skills field (required)
  if ! grep -qF "uses_skills:" "$file"; then
    fail "$skill/SKILL.md frontmatter missing 'uses_skills' field"
    skill_fail=true
  fi

  $skill_fail || ok "$skill/SKILL.md valid"
done

# ── Layer 3: Reference check ──────────────────────────────────────────────────
echo ""
echo "-- references --"

# Build lookup set of registered skills
declare -A reg_set
for skill in "${registered[@]+"${registered[@]}"}"; do
  reg_set["$skill"]=1
done

for skill in "${registered[@]+"${registered[@]}"}"; do
  file="$SKILLS_DIR/$skill/SKILL.md"
  [[ -f "$file" ]] || continue

  # Extract parent_skills list (lines starting with "  - " inside the frontmatter block)
  in_frontmatter=false
  in_parent=false
  in_uses=false
  ref_fail=false

  while IFS= read -r line; do
    # Track frontmatter bounds
    if [[ "$line" == "---" ]]; then
      if ! $in_frontmatter; then
        in_frontmatter=true
      else
        break  # end of frontmatter
      fi
      continue
    fi

    $in_frontmatter || continue

    # Detect field starts
    if echo "$line" | grep -qE "^parent_skills:"; then
      in_parent=true; in_uses=false; continue
    fi
    if echo "$line" | grep -qE "^uses_skills:"; then
      in_uses=true; in_parent=false; continue
    fi
    # Any new top-level key ends the current list
    if echo "$line" | grep -qE "^[a-z_]+:"; then
      in_parent=false; in_uses=false; continue
    fi

    # Parse list items
    if ($in_parent || $in_uses) && echo "$line" | grep -qE "^\s+-\s+"; then
      ref="${line#*- }"
      ref="${ref%"${ref##*[![:space:]]}"}"  # trim trailing whitespace
      if [[ -z "${reg_set[$ref]+_}" ]]; then
        if $in_parent; then
          fail "$skill: parent_skills references '$ref' which is not registered"
          ref_fail=true
        else
          warn "$skill: uses_skills references '$ref' which is not yet registered (planned skill)"
        fi
      fi
    fi
  done < "$file"

  $ref_fail || ok "$skill references valid"
done

# ── Layer 4: Readability check ────────────────────────────────────────────────
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
echo "[payload-depot:skill-check] $PASS passed, $WARN warnings, $FAIL failed"

if [[ $FAIL -gt 0 ]]; then
  echo "[payload-depot:skill-check] ✗ Fix failures then re-run: bash .claude/hooks/payload-depot-skill-check.sh"
  exit 1
fi

echo "[payload-depot:skill-check] ✓ All checks passed"
