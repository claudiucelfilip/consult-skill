#!/bin/bash
# Install the /consult skill for Claude Code

set -e

SKILL_DIR="$HOME/.claude/skills/consult"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# If running via curl pipe, download SKILL.md to temp
if [ ! -f "$SCRIPT_DIR/SKILL.md" ]; then
  SCRIPT_DIR=$(mktemp -d)
  curl -fsSL "https://raw.githubusercontent.com/claudiucelfilip/consult-skill/main/SKILL.md" -o "$SCRIPT_DIR/SKILL.md"
fi

mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"

echo "Installed /consult skill to $SKILL_DIR"
echo ""
echo "Usage: start a new Claude Code session and type:"
echo "  /consult What do you think about this investment report?"
echo ""
echo "Prerequisites: at least one of these CLI tools installed:"
echo "  - claude (Anthropic)    https://claude.ai/claude-code"
echo "  - gemini (Google)       https://github.com/google-gemini/gemini-cli"
echo "  - codex (OpenAI)        https://github.com/openai/codex"
echo "  - agent (Cursor)        https://docs.cursor.com/agent-cli"
