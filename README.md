# Rig

CLI scaffold that bootstraps any project with Claude Code agents, skills, session
templates, config files, and a codebase context index in a single command.

## Quick start

```bash
./rig install
```

## Usage

```bash
./rig install                        # Install for Claude Code (default)
./rig install --target claude-code   # Explicit target
./rig install --force                # Overwrite existing config files
./rig install --dry-run              # Preview without writing files
./rig install --no-hooks             # Skip pre-commit hook
./rig install --no-codebase-index    # Skip ccindex init

./rig list      # List available agents and skills
./rig version   # Print Rig version
./rig help      # Print usage
```

## Requirements

- bash 5+
- git
- `claude` CLI (for Claude Code target)
- `ccindex` (for codebase context indexing — from the bundled `codebase-context/` submodule)

## Documentation

See `SPEC.md` for full specification.
