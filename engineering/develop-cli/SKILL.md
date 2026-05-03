---
name: develop-cli
description: Guide CLI development following clig.dev design principles. Use when building, designing, or reviewing a command-line interface or CLI tool.
---

# Develop CLI

## First — review against principles

Before writing or reviewing any code, read [REFERENCE.md](REFERENCE.md) in full.

Go through each section and identify concrete improvements for the current CLI:
- What is missing or violating this principle?
- What is already correct?
- What is the suggested fix?

Present findings as a prioritised list grouped by **High / Medium / Low**. Let the user pick which fixes they want to implement, then implement only those.

## Quick start

Starting a new CLI from scratch:
1. Name it — lowercase, memorable, easy to type (e.g. `skills`, `gh`, `fly`)
2. Define subcommands, flags vs positional args
3. Define what success and failure output looks like before writing any logic

## Workflow

1. **Design** — clarify structure before writing code
   - Primary command and subcommands?
   - Required vs optional arguments?
   - What does success/failure output look like?

2. **Implement** — build with these defaults
   - Route primary output → `stdout`, logs/errors → `stderr`
   - Return exit code `0` on success, non-zero on failure

3. **Review** — re-read principles after implementing, verify nothing was missed

## Gotchas

- **Secrets in flags** — never accept passwords or tokens via flags (leak into `ps` and shell history). Use files (`--password-file`) or stdin.
- **TTY detection** — check if stdout is a TTY before using color, animations, or interactive prompts. Disable all three when not a TTY.
- **`NO_COLOR`** — respect `NO_COLOR` env var. Also disable color if `TERM=dumb` or `--no-color` is passed.
- **Exit codes** — `0` = success, non-zero = failure. Never exit `0` on error.
- **stderr for errors** — error messages go to `stderr`, not `stdout`.
- **`-` for stdin** — support `-` as a filename to read from stdin.
- **`--no-input`** — provide this flag to disable all interactive prompts for scripting.
- **Responsiveness** — print something within 100ms. Show progress for anything longer.
- **Ctrl-C** — handle INT signal. Exit immediately; skip slow cleanup on second Ctrl-C.
- **Visual output** — use structure (tree, columns, headers) and color. Bold important values, dim secondary info. Output should look good, not just be correct.

## Standard flags

Always use these names when the concept applies:

| Flag | Purpose |
|---|---|
| `-h, --help` | Help |
| `--version` | Version |
| `-q, --quiet` | Less output |
| `-d, --debug` | Debug output |
| `-n, --dry-run` | Show without executing |
| `--json` | Machine-readable output |
| `--no-color` | Disable color |
| `--no-input` | Disable interactive prompts |
| `-f, --force` | Skip confirmations |
| `-o, --output` | Output file |

## Help text checklist

- [ ] Responds to `-h` and `--help`
- [ ] Shows description, 1-2 examples, key flags, pointer to full docs
- [ ] Examples lead — put them before flag lists
- [ ] Suggests corrections on invalid input
- [ ] If piped input expected but TTY given, show help and exit

## Advanced features

See [REFERENCE.md](REFERENCE.md) for full guidance on output formatting, error messages, flags, interactivity, config, subcommands, and distribution.
