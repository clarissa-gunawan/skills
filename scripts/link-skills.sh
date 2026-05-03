#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENTS_DIR="$HOME/.agents/skills"
CLAUDE_DIR="$HOME/.claude/skills"

# Color support
use_color=0
if [ -t 1 ] && [ -z "$NO_COLOR" ] && [ "${TERM:-}" != "dumb" ]; then
  use_color=1
fi

green()  { [ $use_color -eq 1 ] && printf "\033[32m%s\033[0m" "$1" || printf "%s" "$1"; }
red()    { [ $use_color -eq 1 ] && printf "\033[31m%s\033[0m" "$1" || printf "%s" "$1"; }
bold()   { [ $use_color -eq 1 ] && printf "\033[1m%s\033[0m" "$1"  || printf "%s" "$1"; }
dim()    { [ $use_color -eq 1 ] && printf "\033[2m%s\033[0m" "$1"  || printf "%s" "$1"; }

dry_run=0

usage() {
  echo "Usage: $(basename "$0") [options]"
  echo ""
  echo "Symlinks all skills into ~/.agents/skills/ and ~/.claude/skills/"
  echo ""
  echo "Options:"
  echo "  -n, --dry-run   Show what would be linked without making changes"
  echo "  -h, --help      Show this help"
}

for arg in "$@"; do
  case $arg in
    -n|--dry-run) dry_run=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf "%s\n" "$(red "Unknown option: $arg")" >&2; usage >&2; exit 1 ;;
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

linked=0

while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"

  if [ $dry_run -eq 1 ]; then
    printf "  Would link: "
    bold "$skill_name"
    printf "\n"
  else
    ln -sfn "$skill_dir" "$AGENTS_DIR/$skill_name" || {
      printf "%s\n" "$(red "Error:") Failed to link $skill_name to $AGENTS_DIR. Check permissions." >&2
      exit 1
    }
    ln -sfn "$skill_dir" "$CLAUDE_DIR/$skill_name" || {
      printf "%s\n" "$(red "Error:") Failed to link $skill_name to $CLAUDE_DIR. Check permissions." >&2
      exit 1
    }
    printf "  %s " "$(green "✓")"
    bold "$skill_name"
    printf "\n"
  fi

  linked=$((linked + 1))
done < <(find "$REPO_ROOT" -name "SKILL.md" -not -path "*/scripts/*")

if [ $linked -eq 0 ]; then
  printf "%s\n" "$(red "No skills found in $REPO_ROOT")" >&2
  exit 1
fi

echo ""

if [ $dry_run -eq 1 ]; then
  dim "$linked skill(s) would be linked"
  echo ""
else
  bold "$linked skill(s) linked"
  printf " to %s and %s\n" "$AGENTS_DIR" "$CLAUDE_DIR"
  echo ""
  printf "Run "
  bold "scripts/list-skills.sh"
  printf " to see available skills.\n"
fi
