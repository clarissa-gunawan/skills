# CLI Design Principles (clig.dev)

Full reference. Load specific sections as needed.

---

## Output formatting

- Default to human-readable output
- Provide `--json` for machine-readable output
- Provide `--plain` for plain tabular output (one record per line, pipeable to grep/awk)
- Check if stdout is a TTY — disable color and animations when it's not
- Display output on success but keep it brief
- When state changes, explain what happened
- Suggest next commands in multi-step workflows
- Indicate when crossing program boundaries (file reads/writes, network calls)
- Use pagers (e.g. `less -FIRX`) for large output when stdout is interactive
- Use color to highlight, indicate errors, and organize — not for decoration
- Disable color when: stdout isn't a TTY, `NO_COLOR` is set, `TERM=dumb`, `--no-color` passed, or `MYAPP_NO_COLOR` set

## Error messages

- Catch expected errors and rewrite them as actionable human guidance
  - Bad: `EACCES: permission denied`
  - Good: `Can't write to file.txt. Make it writable: chmod +w file.txt`
- Put critical information at the end — eyes rest there
- Group similar errors under explanatory headers
- Use red text sparingly
- For unexpected errors, provide debug info and a bug-report URL
- Consider writing debug logs to a file rather than flooding the terminal

## Arguments and flags

- Prefer flags over positional arguments — clearer, more flexible
- Provide both short (`-h`) and long (`--help`) versions
- Reserve single-letter flags for commonly used options only
- Multiple args are fine for simple multi-file operations
- Two or more args for different purposes is usually a design smell
- Make args, flags, and subcommands order-independent where possible
- If a flag accepts an optional value, allow a keyword like `none` instead of blank

## Interactivity

- Only use prompts if stdin is an interactive terminal (TTY check)
- Provide `--no-input` to disable all prompts
- If `--no-input` is set and required input is missing, fail with clear instructions
- Don't echo passwords as users type — disable terminal echo
- Make it clear how to escape/exit interactive modes
- Ctrl-C must always work; allow a timeout for cleanup

## Subcommands

- Use identical flag names across subcommands
- Use consistent output formatting across subcommands
- Use consistent noun/verb ordering (e.g. `docker container create`)
- Avoid ambiguously similar names (don't have both `update` and `upgrade`)
- Don't create catch-all subcommands for unmapped input
- Don't allow arbitrary abbreviations of subcommand names

## Configuration and environment variables

Configuration precedence (highest to lowest):
1. Flags
2. Running shell environment variables
3. Project-level config (`.env`)
4. User-level config
5. System-wide config

- Follow XDG Base Directory Spec — use `~/.config` for config files
- Env var names: uppercase letters, numbers, underscores only; can't start with number
- Aim for single-line env var values
- Don't commandeer standard POSIX names (`HOME`, `TERM`, `SHELL`, `EDITOR`, etc.)
- Respect `NO_COLOR`, `DEBUG`, `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`, `PAGER`
- Read `.env` files for project-specific config
- **Never store secrets in env vars** — they leak into logs, process listings, and container inspection
- Accept secrets only via credential files, pipes, or secret management services

## Robustness

- Validate all user input early
- Print something within 100ms — responsiveness matters more than speed
- Show progress for long operations
- Parallelize where feasible; be careful about output interleaving
- Implement timeouts for network operations
- Make operations recoverable (resumable from failure where possible)
- Handle INT signal (Ctrl-C): exit immediately, say something first
- Skip time-consuming cleanup on second Ctrl-C
- Design for misuse: scripts, bad connections, multiple instances, unexpected environments

## Naming

- Simple, memorable, lowercase
- Dashes if needed (no underscores)
- Short but not abbreviated to unrecognizable
- Easy to type

## Distribution

- Distribute as a single binary where possible
- If not, use platform package installers
- Place uninstall instructions at the bottom of install docs

## Telemetry

- Never collect usage or crash data without explicit consent
- Be transparent: what you collect, why, how it's anonymized, retention period
- Prefer opt-in over opt-out
- If opt-out, announce clearly on first run
