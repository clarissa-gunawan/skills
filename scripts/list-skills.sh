#!/bin/bash

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Available skills:"
echo ""

while IFS= read -r skill_md; do
  skill_name="$(basename "$(dirname "$skill_md")")"
  description=$(awk '/^description:/{found=1; sub(/^description:[[:space:]]*/,""); print; next} found && /^[^[:space:]]/{exit} found{print}' "$skill_md" | tr -d '\n' | sed 's/^[[:space:]]*//')
  printf "  %-24s %s\n" "$skill_name" "$description"
done < <(find "$REPO_ROOT" -name "SKILL.md" -not -path "*/scripts/*" | sort)
