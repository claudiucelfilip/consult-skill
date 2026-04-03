#!/bin/bash
# Uninstall the /consult skill

SKILL_DIR="$HOME/.claude/skills/consult"

if [ -d "$SKILL_DIR" ]; then
  rm -rf "$SKILL_DIR"
  echo "Removed /consult skill from $SKILL_DIR"
else
  echo "Skill not installed at $SKILL_DIR"
fi
