---
name: develop-cli
description: Guide CLI development following clig.dev design principles. Use when building, designing, or reviewing a command-line interface or CLI tool.
---

# Develop CLI

## First — review against principles

Go through each category below and identify concrete improvements for the current CLI. For each category, report:
- What is already correct
- What is missing or violating the principle
- Suggested fix

Present findings grouped by category, each with a **High / Medium / Low** priority. Let the user pick which fixes to implement, then implement only those.

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

3. **Review** — go through each principle category, verify nothing was missed

## Principles

### Output formatting

- Prioritize human-readable output by default
- Provide `--json` for machine-readable output
- Provide `--plain` for plain tabular output (one record per line, pipeable to grep/awk)
- Display output on success but keep it brief
- When state changes, tell the user what changed
- Make it easy to see the current state of the system
- Suggest next commands in multi-step workflows
- Indicate when crossing program boundaries (file reads/writes, network calls)
- Increase information density with ASCII art where helpful
- Use color to highlight, indicate errors, and organize — not for decoration
- Use symbols and emoji where they add clarity, not clutter
- Disable color when: stdout isn't a TTY, `NO_COLOR` is set, `TERM=dumb`, `--no-color` passed, or `MYAPP_NO_COLOR` set
- Don't display animations if stdout is not a TTY
- Don't output debug-only information by default — only in verbose/debug mode
- Don't treat `stderr` like a log file by default
- Use pagers (e.g. `less -FIRX`) for large output when stdout is interactive
- Use structure (tree, columns, headers) — bold important values, dim secondary info

### Help text

- Display full help when `-h` or `--help` is passed
- Display concise help by default (description, 1-2 examples, key flags, pointer to full docs)
- For git-like tools: support `help`, `help <subcommand>`, `<subcommand> --help`, `<subcommand> -h`
- Lead with examples — put them before flag lists
- Display most common flags and commands first
- Use formatting in help text (bold headings, structured layout)
- Link to web documentation from help text
- Provide a support path for feedback and issues
- Suggest corrections when user input appears mistaken
- If command expects piped input and stdin is a TTY, display help and exit

### Documentation

- Provide web-based documentation for searchability and linking
- Provide terminal-based documentation via the tool itself
- Consider man pages for discoverability
- Link directly to specific documentation pages from help text

### Error messages

- Catch expected errors and rewrite as actionable human guidance
  - Bad: `EACCES: permission denied`
  - Good: `Can't write to file.txt. Make it writable: chmod +w file.txt`
- Maintain high signal-to-noise ratio — group similar errors, suppress noise
- Put critical information at the end — eyes rest there
- Use red text sparingly
- For unexpected errors, provide debug info and a bug-report URL
- Make it effortless to submit bug reports — pre-populate URLs where possible
- Consider writing debug logs to a file rather than flooding the terminal

### Arguments and flags

- Prefer flags over positional arguments — clearer, more flexible
- Provide both short (`-h`) and long (`--help`) versions for all flags
- Reserve single-letter flags for commonly used options only
- Multiple args are fine for simple multi-file operations
- Don't use two or more arguments for different things
- Make the default the right choice for most users
- Prompt for user input if not provided — but never require a prompt (support `--no-input`)
- Confirm before doing anything dangerous
- Make args, flags, and subcommands order-independent where possible
- Support `-` as a filename to read from stdin / write to stdout
- Allow special words like `none` for optional flag values
- Never accept secrets via flags — they leak into `ps` and shell history
- Use `--password-file` or stdin for secrets instead

Standard flag names:

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

### Interactivity

- Only use prompts if stdin is an interactive terminal (TTY check)
- Provide `--no-input` to disable all prompts
- If `--no-input` is set and required input is missing, fail with clear instructions
- Don't echo passwords as users type — disable terminal echo
- Make it clear how to escape/exit interactive modes; document escape sequences if needed
- Ctrl-C must always work

### Signals and control characters

- Exit immediately when user hits Ctrl-C (INT signal)
- Say something before starting cleanup
- Add a timeout to cleanup code
- Skip long cleanup operations on second Ctrl-C
- Expect to start in a state where cleanup hasn't run — design accordingly

### Subcommands

- Be consistent across subcommands — identical flag names, consistent output format
- Use consistent noun/verb ordering (e.g. `docker container create`)
- Use consistent names across multiple levels of subcommands
- Avoid ambiguously similar names (don't have both `update` and `upgrade`)
- Don't create catch-all subcommands for unmapped input
- Don't allow arbitrary abbreviations of subcommand names

### Configuration

Configuration precedence (highest to lowest):
1. Flags
2. Running shell environment variables
3. Project-level config (`.env`)
4. User-level config
5. System-wide config

- Use flags for config that varies per invocation
- Use flags and env vars for stable, machine-specific config
- Use version-controlled files for project-stable config
- Follow XDG Base Directory Spec — use `~/.config` for config files
- Ask user consent before modifying files outside your program
- Don't use `.env` as a substitute for proper config files

### Environment variables

- Use for behavior that varies with the context the command is run in
- Names: uppercase letters, numbers, underscores only; can't start with a number
- Aim for single-line values
- Don't commandeer standard POSIX names
- Respect general-purpose variables: `NO_COLOR`, `DEBUG`, `EDITOR`, `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`, `NO_PROXY`, `SHELL`, `TERM`, `TERMINFO`, `TERMCAP`, `TMPDIR`, `HOME`, `PAGER`, `LINES`, `COLUMNS`
- Read from `.env` where appropriate; don't use it as a substitute for proper config
- Never read secrets from environment variables

### Robustness

- Validate all user input early
- Print something within 100ms — responsiveness matters more than speed
- Show progress for long operations; include estimated time remaining where possible
- Parallelize where feasible — use libraries, be careful about output interleaving
- Implement timeouts for network operations
- Make operations recoverable (resumable from failure where possible)
- Make it crash-only — fail fast, defer cleanup; don't rely on graceful shutdown
- Design for misuse: scripts, bad connections, multiple instances, unexpected environments

### Future-proofing

- Keep changes additive where possible — add flags rather than change existing behaviour
- Warn before non-additive changes; detect when users have updated and suppress the warning
- Changing human-readable output is usually OK — encourage scripts to use `--json` or `--plain`
- Don't create a catch-all subcommand
- Don't create time bombs — avoid external dependencies that could expire or disappear

### Naming

- Simple, memorable, lowercase word
- Dashes if needed — no underscores
- Short but not abbreviated to unrecognizable
- Easy to type

### Distribution

- Distribute as a single binary where possible
- If not, use platform package installers
- Make it easy to uninstall — place instructions at the bottom of install docs

### Telemetry

- Never collect usage or crash data without explicit consent
- Be transparent: what you collect, why, how it's anonymized, retention period
- Prefer opt-in over opt-out; if opt-out, announce clearly on first run
- Consider alternatives: instrument web docs, track downloads, talk to users directly
