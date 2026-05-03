#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENTS_DIR="$HOME/.agents/skills"
CLAUDE_DIR="$HOME/.claude/skills"

# Color support
use_color=0
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-}" != "dumb" ]; then
  use_color=1
fi

green()  { [ $use_color -eq 1 ] && printf "\033[32m%s\033[0m" "$1" || printf "%s" "$1"; }
red()    { [ $use_color -eq 1 ] && printf "\033[31m%s\033[0m" "$1" || printf "%s" "$1"; }
bold()   { [ $use_color -eq 1 ] && printf "\033[1m%s\033[0m" "$1"  || printf "%s" "$1"; }
dim()    { [ $use_color -eq 1 ] && printf "\033[2m%s\033[0m" "$1"  || printf "%s" "$1"; }

dry_run=0
quiet=0

usage() {
  echo "Usage: $(basename "$0") [options]"
  echo ""
  echo "Examples:"
  echo "  $(basename "$0")            Install all skills"
  echo "  $(basename "$0") --dry-run  Preview what would be installed"
  echo ""
  echo "Copies all skills into ~/.agents/skills/ and ~/.claude/skills/"
  echo "Existing skills are always overwritten."
  echo ""
  echo "Options:"
  echo "  -n, --dry-run    Show what would be installed without making changes"
  echo "  -q, --quiet      Only print summary, suppress per-skill output"
  echo "  --no-color       Disable colored output"
  echo "  -h, --help       Show this help"
}

for arg in "$@"; do
  case $arg in
    -n|--dry-run) dry_run=1 ;;
    -q|--quiet)   quiet=1 ;;
    --no-color)   use_color=0 ;;
    -h|--help)    usage; exit 0 ;;
    *) printf "%s\n" "$(red "Error:") Unknown option: $arg. Run $(basename "$0") --help for usage." >&2; exit 1 ;;
  esac
done

if [ $dry_run -eq 1 ]; then
  printf "%s\n\n" "$(dim "Dry run — no changes will be made")"
fi

if [ $dry_run -eq 0 ]; then
  mkdir -p "$AGENTS_DIR" "$CLAUDE_DIR" || {
    printf "%s\n" "$(red "Error:") Can't create skill directories. Check permissions on $HOME." >&2
    exit 1
  }
fi

installed=0

while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"

  if [ $dry_run -eq 1 ]; then
    if [ $quiet -eq 0 ]; then
      printf "  Would install: "
      bold "$skill_name"
      printf "\n"
    fi
  else
    rm -rf "${AGENTS_DIR:?}/$skill_name" "${CLAUDE_DIR:?}/$skill_name"
    cp -r "$skill_dir" "$AGENTS_DIR/$skill_name" || {
      printf "%s\n" "$(red "Error:") Failed to copy $skill_name to $AGENTS_DIR." >&2
      exit 1
    }
    cp -r "$skill_dir" "$CLAUDE_DIR/$skill_name" || {
      printf "%s\n" "$(red "Error:") Failed to copy $skill_name to $CLAUDE_DIR." >&2
      exit 1
    }
    if [ $quiet -eq 0 ]; then
      printf "  %s " "$(green "✓")"
      bold "$skill_name"
      printf "\n"
    fi
  fi

  installed=$((installed + 1))
done < <(find "$REPO_ROOT" -name "SKILL.md" -not -path "*/scripts/*" | sort)

if [ $installed -eq 0 ]; then
  printf "%s\n" "$(red "Error:") No skills found in $REPO_ROOT" >&2
  exit 1
fi

echo ""

if [ $dry_run -eq 1 ]; then
  dim "$installed skill(s) would be installed"
  echo ""
else
  bold "$installed skill(s) installed"
  printf " to %s and %s\n" "$AGENTS_DIR" "$CLAUDE_DIR"
  echo ""
  printf "Run "
  bold "scripts/list-skills.sh"
  printf " to see available skills.\n"
fi
