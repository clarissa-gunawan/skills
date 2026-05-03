# skills

Personal agent skills library. Works with Claude Code and any [Agent Skills](https://agentskills.io)-compatible tool.

## Install

```bash
bash scripts/install-skills.sh
```

Copies all skills into `~/.agents/skills/` and `~/.claude/skills/`. Re-run after pulling updates.

## List available skills

```bash
bash scripts/list-skills.sh
```

## Structure

```
skills/
├── productivity/     # communication and workflow skills
└── engineering/      # code and technical workflow skills
scripts/              # install and utility scripts
```

## Adding a new skill

Run `/write-a-skill` in Claude Code.
