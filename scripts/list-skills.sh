#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Color support
use_color=0
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-}" != "dumb" ]; then
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

# Collect skills into parallel arrays. `find | sort` groups by category
# (path-sorted), so we can walk once and detect category transitions.
names=()
descs=()
cats=()

while IFS= read -r skill_md; do
  names+=("$(basename "$(dirname "$skill_md")")")
  cats+=("$(basename "$(dirname "$(dirname "$skill_md")")")")
  descs+=("$(awk '/^description:/{found=1; sub(/^description:[[:space:]]*/,""); print; next} found && /^[^[:space:]]/{exit} found{print}' "$skill_md" | tr -d '\n' | sed 's/^[[:space:]]*//')")
done < <(find "$REPO_ROOT" -name "SKILL.md" -not -path "*/scripts/*" | sort)

total=${#names[@]}

if [ $total -eq 0 ]; then
  printf "No skills found.\n" >&2
  exit 1
fi

echo ""

prev_cat=""
for i in "${!names[@]}"; do
  skill_name="${names[$i]}"
  description="${descs[$i]}"
  cat="${cats[$i]}"
  next_cat="${cats[$((i+1))]:-}"

  if [ "$cat" != "$prev_cat" ]; then
    [ -n "$prev_cat" ] && echo ""
    printf "  "
    bold "$cat"
    echo ""
  fi

  if [ "$cat" != "$next_cat" ]; then
    prefix="  └── "
  else
    prefix="  ├── "
  fi

  # indent for continuation lines aligns after prefix + name + separator
  desc_start=$((${#prefix} + ${#skill_name} + 2))
  indent="$(printf '%*s' "$desc_start" '')"
  available=$((term_width - desc_start))

  printf "%s" "$prefix"
  bold "$skill_name"
  printf "  "
  wrap_text "$description" "$available" "$indent"

  prev_cat="$cat"
done

echo ""
