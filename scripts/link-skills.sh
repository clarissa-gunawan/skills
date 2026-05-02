#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENTS_DIR="$HOME/.agents/skills"
CLAUDE_DIR="$HOME/.claude/skills"

mkdir -p "$AGENTS_DIR" "$CLAUDE_DIR"

linked=0

while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"

  ln -sfn "$skill_dir" "$AGENTS_DIR/$skill_name"
  ln -sfn "$skill_dir" "$CLAUDE_DIR/$skill_name"

  echo "Linked: $skill_name"
  linked=$((linked + 1))
done < <(find "$REPO_ROOT" -name "SKILL.md" -not -path "*/scripts/*")

echo ""
echo "$linked skill(s) linked to $AGENTS_DIR and $CLAUDE_DIR"
