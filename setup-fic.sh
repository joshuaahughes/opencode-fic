#!/usr/bin/env bash
# setup-fic.sh — Install the FIC OpenCode infrastructure into your project
# Usage: ./setup-fic.sh [target-project-dir]
#
# What this does:
#   1. Copies .opencode/ config (agents, commands, skills) into your project
#   2. Creates agent_docs/ templates (if not present)
#   3. Creates a thoughts/ symlink pointing to ~/thoughts/<project-name>
#   4. Adds AGENTS.md (if not present)
#   5. Updates .gitignore

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.}"
TARGET="$(cd "$TARGET" && pwd)"
PROJECT_NAME="$(basename "$TARGET")"
THOUGHTS_DIR="$HOME/thoughts/$PROJECT_NAME"

echo "→ Installing FIC infrastructure into: $TARGET"
echo "→ Project name: $PROJECT_NAME"
echo ""

# 1. Copy .opencode config
echo "[1/5] Copying .opencode config..."
if [ -d "$TARGET/.opencode" ]; then
  echo "  .opencode/ already exists — merging (existing files will NOT be overwritten)"
  cp -rn "$SCRIPT_DIR/.opencode/." "$TARGET/.opencode/" 2>/dev/null || true
else
  cp -r "$SCRIPT_DIR/.opencode" "$TARGET/.opencode"
fi
echo "  ✓ .opencode/"

# 2. Copy agent_docs templates
echo "[2/5] Creating agent_docs templates..."
if [ -d "$TARGET/agent_docs" ]; then
  echo "  agent_docs/ already exists — skipping"
else
  cp -r "$SCRIPT_DIR/agent_docs" "$TARGET/agent_docs"
  echo "  ✓ agent_docs/ (fill in the templates!)"
fi

# 3. Create global thoughts dir and symlink
echo "[3/5] Setting up thoughts/ directory..."
mkdir -p "$THOUGHTS_DIR/research" "$THOUGHTS_DIR/plans" "$THOUGHTS_DIR/progress"
if [ -L "$TARGET/thoughts" ]; then
  echo "  thoughts/ symlink already exists"
elif [ -d "$TARGET/thoughts" ]; then
  echo "  thoughts/ directory already exists — skipping symlink"
else
  ln -s "$THOUGHTS_DIR" "$TARGET/thoughts"
  echo "  ✓ thoughts/ → $THOUGHTS_DIR"
fi

# 4. Create AGENTS.md if not present
echo "[4/5] Checking AGENTS.md..."
if [ -f "$TARGET/AGENTS.md" ]; then
  echo "  AGENTS.md already exists — skipping"
elif [ -f "$TARGET/CLAUDE.md" ]; then
  echo "  CLAUDE.md found — skipping (rename to AGENTS.md if you want to use it with opencode)"
else
  cp "$SCRIPT_DIR/AGENTS.md" "$TARGET/AGENTS.md"
  echo "  ✓ AGENTS.md (edit this with your project details!)"
fi

# 5. Update .gitignore
echo "[5/5] Updating .gitignore..."
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
add_if_missing ".opencode/local.json" "$GITIGNORE"
echo "  ✓ .gitignore updated"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ FIC infrastructure installed!"
echo ""
echo "Next steps:"
echo "  1. Edit AGENTS.md — fill in your project's What/Stack/How"
echo "  2. Fill in agent_docs/*.md with real details about your project"  
echo "  3. Optionally tune .opencode/opencode.json (test commands, model preferences)"
echo ""
echo "Workflow:"
echo "  /research [topic]              — Phase 1: explore, no changes"
echo "  /plan thoughts/research/X.md   — Phase 2: plan from research"
echo "  /implement thoughts/plans/X.md — Phase 3: execute phase by phase"
echo "  /checkpoint [topic]            — Save session state to resume later"
echo "  /commit                        — Generate conventional commit message"
echo "  /pr [plan-doc]                 — Generate PR description"
echo ""
echo "Thoughts stored at: $THOUGHTS_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
