---
name: pr-update
description: Compile a work update from your recent GitHub PRs (including co-authored ones opened by teammates) and DM it to yourself on Slack, continuing from the previous update. Use when the user says "/pr-update", "DM myself an update", "PR update", "standup update", or "what did I do this week".
---

# PR Update

Generate a concise work-update from the user's recent GitHub PR activity and send it as a Slack DM to themselves. Each run continues from the previous update (no repeats; drafts that shipped get promoted to Merged).

## Defaults (derive, don't assume)

- **GitHub login:** `gh api user --jq .login`
- **Org:** default `dyna-robotics` (override if the user names another).
- **Slack target:** the current logged-in Slack user — DM yourself by passing your own `user_id` as `channel_id`. The Slack tools surface the logged-in `user_id` at call time; use that. Never post to a shared channel unless the user explicitly asks.

## Process

### 1. Find the previous update (sets the time window)

Read the self-DM channel history (`slack_read_channel` on your own DM) and find the most recent message whose text starts with `Update - ` (the header below). Use **its timestamp as the `since` cutoff** and keep its PR list so you can:
- skip items already reported, and
- promote anything that was `(draft)` last time and is now merged.

If no previous update exists, default `since` to **7 days ago** and say so.

### 2. Gather PRs — TWO sources (do not skip the second)

`gh search prs` filters by **PR opener**, so PRs a teammate opened but you did the commits on (co-authored) are invisible to an author filter. Cover both:

**A. PRs you opened:**
```bash
gh search prs --author <login> --owner <org> --sort updated --limit 40 \
  --json number,title,state,url,isDraft,updatedAt,repository
```

**B. Co-authored PRs opened by others** (the blind spot):
```bash
gh search prs --owner <org> --involves <login> --sort updated --limit 40 \
  --json number,title,state,url,isDraft,updatedAt
# For each candidate NOT already in list A, confirm your authorship:
gh pr view <n> --repo <org>/<repo> --json commits \
  --jq '[.commits[].authors[].login] | index("<login>")'
# Keep it only if that returns a non-null index. Label it "(co-authored; opened by <opener>)".
```

### 3. Classify into three buckets (HYBRID windowing)

The window applies **only to Done**. Open work carries forward every run until it merges, so the update always reflects current state — right for a recurring (e.g. Tue/Thu) cadence.

- **Done** — `state == "merged"` **AND merged since `since`** (strict delta: only what shipped this cycle; promote any prior-update drafts now merged).
- **In Progress** — **every** currently-open PR where NOT `isDraft`, regardless of when last touched (carry-forward).
- **Backlog** — **every** currently-open PR where `isDraft`, regardless of when last touched (carry-forward).
- **Exclude** `state == "closed"` (unmerged/superseded) by default — mention in chat that you skipped N closed-unmerged PRs and offer to include them.

Do NOT apply the `since` cutoff to open PRs — only to Done. (If an open PR has had zero activity for a long time, still list it; flag it as possibly stale so the user can prune.)

### 4. Format

Concise, one line per PR, most impactful first. Every line states **what changed AND its impact/goal** — not just the change — so the reader sees why it mattered. Rewrite the conventional-commit title into plain language; keep it to ~one sentence and cut filler. Keep the PR link:

```
- **<area>:** <what changed> — <why it matters / the goal> — [#<n>](<url>)
```

Group under **Done**, **In Progress**, and **Backlog** (in that order). Drafts live under Backlog, so no per-line draft tag is needed. Omit a bucket only if it has no items.

Header (first line): `**Update - <start>-<end>, <year>**` — a **date range** where `start` = the date of your previous update and `end` = today. Examples: `Update - Jul 8-14, 2026`; cross-month `Update - Jul 29 - Aug 4, 2026`; cross-year include both years. On the first-ever run (no prior update), set `start` = 7 days ago.
Second line (italic, transparency): `_Done = merged this range; In Progress/Backlog = current state._`

### 5. Send + report

1. Show the compiled update in the chat first.
2. Send it as a Slack DM to yourself (your `user_id` as `channel_id`).
3. Return the Slack message link.
4. Note the source split (opened by you vs co-authored) so attribution is clear, and remind the user they can edit before posting it to a team channel.

## Notes

- Keep it factual — only claim PRs where your commits actually appear.
- If the user points you at a specific PR you missed, it's almost always a co-authored one (step 2B) — add it and re-send.
