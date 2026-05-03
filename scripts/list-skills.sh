#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Color support
use_color=0
if [ -t 1 ] && [ -z "$NO_COLOR" ] && [ "${TERM:-}" != "dumb" ]; then
  use_color=1
fi

bold() { [ $use_color -eq 1 ] && printf "\033[1m%s\033[0m" "$1" || printf "%s" "$1"; }
dim()  { [ $use_color -eq 1 ] && printf "\033[2m%s\033[0m" "$1" || printf "%s" "$1"; }

term_width=$(tput cols 2>/dev/null || echo 100)

# Word-wrap text at max_width, indenting continuation lines with indent_str
wrap_text() {
  local text="$1"
  local max_width="$2"
  local indent="$3"
  local line=""
  local first=1

  for word in $text; do
    if [ -z "$line" ]; then
      line="$word"
    elif [ $((${#line} + 1 + ${#word})) -le $max_width ]; then
      line="$line $word"
    else
      if [ $first -eq 1 ]; then
        dim "$line"
        first=0
      else
        printf "%s" "$indent"
        dim "$line"
      fi
      echo ""
      line="$word"
    fi
  done

  # Print last line
  if [ -n "$line" ]; then
    if [ $first -eq 1 ]; then
      dim "$line"
    else
      printf "%s" "$indent"
      dim "$line"
    fi
    echo ""
  fi
}

declare -A category_skills
categories=()

while IFS= read -r skill_md; do
  skill_name="$(basename "$(dirname "$skill_md")")"
  category="$(basename "$(dirname "$(dirname "$skill_md")")")"
  description=$(awk '/^description:/{found=1; sub(/^description:[[:space:]]*/,""); print; next} found && /^[^[:space:]]/{exit} found{print}' "$skill_md" | tr -d '\n' | sed 's/^[[:space:]]*//')

  if [[ -z "${category_skills[$category]+x}" ]]; then
    categories+=("$category")
    category_skills[$category]=""
  fi
  category_skills[$category]+="$skill_name|$description"$'\n'
done < <(find "$REPO_ROOT" -name "SKILL.md" -not -path "*/scripts/*" | sort)

if [ ${#categories[@]} -eq 0 ]; then
  printf "No skills found.\n" >&2
  exit 1
fi

echo ""

for category in "${categories[@]}"; do
  printf "  "
  bold "$category"
  echo ""

  entries=()
  while IFS= read -r entry; do
    [ -n "$entry" ] && entries+=("$entry")
  done <<< "${category_skills[$category]}"

  total=${#entries[@]}
  for i in "${!entries[@]}"; do
    entry="${entries[$i]}"
    skill_name="${entry%%|*}"
    description="${entry#*|}"

    if [ $((i + 1)) -lt $total ]; then
      prefix="  ├── "
    else
      prefix="  └── "
    fi

    # indent for continuation lines aligns after prefix + name + separator
    desc_start=$((${#prefix} + ${#skill_name} + 2))
    indent="$(printf '%*s' "$desc_start" '')"
    available=$((term_width - desc_start))

    printf "%s" "$prefix"
    bold "$skill_name"
    printf "  "
    wrap_text "$description" "$available" "$indent"
  done

  echo ""
done
