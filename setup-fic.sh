#!/usr/bin/env bash
# setup-fic.sh — Install the FIC infrastructure into your project
# Usage: ./setup-fic.sh [target-project-dir] [--opencode|--gemini|--both]
#
# What this does:
#   1. Copies config (agents, commands, skills) into your project
#   2. Creates agent_docs/ templates (if not present)
#   3. Creates a thoughts/ symlink pointing to ~/thoughts/<project-name>
#   4. Adds context file (AGENTS.md and/or GEMINI.md)
#   5. Updates .gitignore

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.}"
TARGET="$(cd "$TARGET" && pwd)"
PROJECT_NAME="$(basename "$TARGET")"
THOUGHTS_DIR="$HOME/thoughts/$PROJECT_NAME"

MODE="both"
for arg in "$@"; do
  case "$arg" in
    --opencode) MODE="opencode" ;;
    --gemini) MODE="gemini" ;;
    --both) MODE="both" ;;
  esac
done

echo "→ Installing FIC infrastructure into: $TARGET"
echo "→ Project name: $PROJECT_NAME"
echo "→ Mode: $MODE"
echo ""

# Determine which configs to install
INSTALL_OPENCODE=false
INSTALL_GEMINI=false
case "$MODE" in
  opencode) INSTALL_OPENCODE=true ;;
  gemini) INSTALL_GEMINI=true ;;
  both) INSTALL_OPENCODE=true; INSTALL_GEMINI=true ;;
esac

# Track step number
STEP=0

# 1. Copy opencode config
if [ "$INSTALL_OPENCODE" = true ]; then
  STEP=$((STEP + 1))
  echo "[$STEP/5] Copying .opencode config..."
  if [ -d "$TARGET/.opencode" ]; then
    echo "  .opencode/ already exists — merging (existing files will NOT be overwritten)"
    cp -rn "$SCRIPT_DIR/.opencode/." "$TARGET/.opencode/" 2>/dev/null || true
  else
    cp -r "$SCRIPT_DIR/.opencode" "$TARGET/.opencode"
  fi
  echo "  ✓ .opencode/"
fi

# 2. Copy gemini config
if [ "$INSTALL_GEMINI" = true ]; then
  STEP=$((STEP + 1))
  echo "[$STEP/5] Copying .gemini config..."
  mkdir -p "$TARGET/.gemini"
  
  if [ -d "$SCRIPT_DIR/.gemini" ]; then
    if [ -d "$TARGET/.gemini" ]; then
      echo "  .gemini/ already exists — merging (existing files will NOT be overwritten)"
      cp -rn "$SCRIPT_DIR/.gemini/." "$TARGET/.gemini/" 2>/dev/null || true
    else
      cp -r "$SCRIPT_DIR/.gemini" "$TARGET/.gemini"
    fi
  else
    echo "  .gemini/ template not found, creating from .opencode..."
    create_gemini_config_from_opencode
  fi
  echo "  ✓ .gemini/"
fi

# 3. Copy agent_docs templates
STEP=$((STEP + 1))
echo "[$STEP/5] Creating agent_docs templates..."
if [ -d "$TARGET/agent_docs" ]; then
  echo "  agent_docs/ already exists — skipping"
else
  cp -r "$SCRIPT_DIR/agent_docs" "$TARGET/agent_docs"
  echo "  ✓ agent_docs/ (fill in the templates!)"
fi

# 4. Create global thoughts dir and symlink
STEP=$((STEP + 1))
echo "[$STEP/5] Setting up thoughts/ directory..."
mkdir -p "$THOUGHTS_DIR/research" "$THOUGHTS_DIR/plans" "$THOUGHTS_DIR/progress"
if [ -L "$TARGET/thoughts" ]; then
  echo "  thoughts/ symlink already exists"
elif [ -d "$TARGET/thoughts" ]; then
  echo "  thoughts/ directory already exists — skipping symlink"
else
  ln -s "$THOUGHTS_DIR" "$TARGET/thoughts"
  echo "  ✓ thoughts/ → $THOUGHTS_DIR"
fi

# 5. Create context files
STEP=$((STEP + 1))
echo "[$STEP/5] Checking context files..."

if [ "$INSTALL_OPENCODE" = true ]; then
  if [ -f "$TARGET/AGENTS.md" ]; then
    echo "  AGENTS.md already exists — skipping"
  elif [ -f "$TARGET/CLAUDE.md" ]; then
    echo "  CLAUDE.md found — skipping (rename to AGENTS.md if you want to use it)"
  else
    cp "$SCRIPT_DIR/AGENTS.md" "$TARGET/AGENTS.md"
    echo "  ✓ AGENTS.md (edit this with your project details!)"
  fi
fi

if [ "$INSTALL_GEMINI" = true ]; then
  if [ -f "$TARGET/GEMINI.md" ]; then
    echo "  GEMINI.md already exists — skipping"
  else
    cp "$SCRIPT_DIR/GEMINI.md" "$TARGET/GEMINI.md" 2>/dev/null || create_gemini_md
    echo "  ✓ GEMINI.md (edit this with your project details!)"
  fi
fi

# 6. Update .gitignore
STEP=$((STEP + 1))
echo "[$STEP/5] Updating .gitignore..."
GITIGNORE="$TARGET/.gitignore"
if [ ! -f "$GITIGNORE" ]; then
  touch "$GITIGNORE"
fi

add_if_missing() {
  local line="$1"
  local file="$2"
  grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

add_if_missing "thoughts/" "$GITIGNORE"
[ "$INSTALL_OPENCODE" = true ] && add_if_missing ".opencode/local.json" "$GITIGNORE"
[ "$INSTALL_GEMINI" = true ] && add_if_missing ".gemini/.env" "$GITIGNORE"
echo "  ✓ .gitignore updated"

create_gemini_config_from_opencode() {
  mkdir -p "$TARGET/.gemini/commands" "$TARGET/.gemini/agents" "$TARGET/.gemini/skills"
  
  # Convert opencode commands to gemini TOML
  if [ -d "$SCRIPT_DIR/.opencode/commands" ]; then
    for cmd in "$SCRIPT_DIR/.opencode/commands"/*.md; do
      [ -f "$cmd" ] || continue
      name=$(basename "$cmd" .md)
      convert_command_to_toml "$cmd" "$TARGET/.gemini/commands/$name.toml"
    done
  fi
  
  # Copy agents (they're similar format)
  if [ -d "$SCRIPT_DIR/.opencode/agents" ]; then
    cp -r "$SCRIPT_DIR/.opencode/agents"/* "$TARGET/.gemini/agents/" 2>/dev/null || true
  fi
  
  # Copy skills
  if [ -d "$SCRIPT_DIR/.opencode/skills" ]; then
    cp -r "$SCRIPT_DIR/.opencode/skills" "$TARGET/.gemini/skills/fic-workflow"
  fi
  
  # Copy settings.json if exists, otherwise create basic one
  if [ -f "$SCRIPT_DIR/.gemini/settings.json" ]; then
    cp "$SCRIPT_DIR/.gemini/settings.json" "$TARGET/.gemini/settings.json"
  else
    cat > "$TARGET/.gemini/settings.json" << 'EOF'
{
  "context": {
    "fileName": ["GEMINI.md", "AGENTS.md"]
  }
}
EOF
  fi
}

convert_command_to_toml() {
  local src="$1"
  local dst="$2"
  
  # Extract description from YAML frontmatter
  desc=$(sed -n 's/^description: "\?\(.*\)"\?/\1/p' "$src" 2>/dev/null | head -1)
  
  # Extract the prompt content (everything after the ---)
  content=$(sed '1,/^---$/d' "$src")
  
  # Convert $ARGUMENTS to {{args}}
  content=$(echo "$content" | sed 's/\$ARGUMENTS/{{args}}/g')
  
  # Write TOML file
  cat > "$dst" << TOML
description = "${desc:-FIC command}"
prompt = """${content}"""
TOML
}

create_gemini_md() {
  cat > "$TARGET/GEMINI.md" << 'EOF'
# Project Agent Configuration

## What
[Replace with a 2-sentence description of your project and its purpose.]

## Stack
[Replace with your key technologies, e.g. TypeScript, Go, React, Postgres, etc.]

## How to verify changes
```
# Replace with your test/build commands
npm test
npm run typecheck
npm run build
```

## Workflow: FIC (Frequent Intentional Compaction)

For any non-trivial task (touches more than 1-2 files), use the FIC workflow:

1. `/research [topic]` — explore first, write nothing
2. `/plan thoughts/research/[output].md` — plan from research  
3. `/implement thoughts/plans/[output].md` — execute phase by phase

Before starting a multi-file task, activate the fic-workflow skill:
> "Load the fic-workflow skill before we begin."

**Never exceed 60% context in any session. Start a new session at every phase boundary.**

## Agent Docs
Only read these when relevant to your current task:

- `agent_docs/architecture.md` — system structure and component relationships
- `agent_docs/testing.md` — how to run, write, and interpret tests
- `agent_docs/conventions.md` — code style, patterns, and naming conventions
- `agent_docs/database.md` — schema, migrations, and query patterns (if applicable)
- `agent_docs/deployment.md` — build, release, and deploy process (if applicable)

## Hard Rules
- Do not modify `GEMINI.md` or files in `.gemini/` without explicit instruction
- Do not install new dependencies without asking
- Prefer reading existing code patterns over inventing new ones
- If reality diverges from the plan, surface it immediately — do not improvise silently
EOF
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ FIC infrastructure installed!"
echo ""

if [ "$INSTALL_OPENCODE" = true ]; then
  echo "OpenCode config:"
  echo "  .opencode/ — agents, commands, skills"
  echo "  AGENTS.md — context file"
fi

if [ "$INSTALL_GEMINI" = true ]; then
  echo "Gemini CLI config:"
  echo "  .gemini/ — commands, agents, skills"
  echo "  GEMINI.md — context file"
fi

echo ""
echo "Next steps:"
echo "  1. Edit AGENTS.md and/or GEMINI.md — fill in your project's What/Stack/How"
echo "  2. Fill in agent_docs/*.md with real details about your project"  
if [ "$INSTALL_OPENCODE" = true ]; then
  echo "  3. Optionally tune .opencode/opencode.json (test commands, model preferences)"
fi
if [ "$INSTALL_GEMINI" = true ]; then
  echo "  3. Optionally tune .gemini/settings.json"
fi

echo ""
echo "Workflow commands:"
echo "  /research [topic]              — Phase 1: explore, no changes"
echo "  /plan [research-doc]            — Phase 2: plan from research"
echo "  /implement [plan-doc]          — Phase 3: execute phase by phase"
echo "  /checkpoint [topic]            — Save session state to resume later"
echo "  /git:commit                    — Generate conventional commit message"
echo "  /pr [plan-doc]                 — Generate PR description"
