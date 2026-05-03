---
name: research
description: Research a topic or compare options using reputable sources, synthesise into a readable reference document, and discuss findings. Use when the user wants to understand a topic, explore a concept, research laws or codes, compare products or services, or build a reference document they can return to later.
---

# Research

A structured research session that clarifies your goal, gathers evidence from reputable sources, surfaces what you might be missing, and stays in conversation with you throughout.

## Quick start

Invoke with a topic or question:
- `/research Australian home office tax deductions`
- `/research compare trail runners for technical terrain`
- `/research what is domain driven design`

Results are saved to `~/Documents/research/YYYY-MM-DD-<topic>.md` by default. To save elsewhere, say so when invoking: `/research <topic> — save to ./research`

The skill will clarify your goal before searching anything.

## Modes

Determine the mode from the user's goal before starting:

- **Understand** — learn about a topic, build a reference (tax codes, how something works, educational concepts)
- **Compare** — evaluate options against criteria to support a decision (trail runners, educational courses, tools)

Both modes follow the same cycle and both stay in discussion. The output shape differs.

## Framework

Every session follows this cycle:

```
Goal → Questions → Evidence → Synthesis → Gaps → Discuss → (repeat)
```

This is intentionally iterative — research rarely ends in one pass. Each discussion can spawn a new cycle.

## Workflow

### 1. Clarify the goal

Before searching anything, ask:

- What decision are you trying to make, or what do you want to understand?
- What will you do with this information?
- What do you already know about this topic?
- Are there constraints (jurisdiction, timeframe, context)?

Do not skip this step. A vague topic produces vague research.

### 2. Generate research questions

**Understand mode:** Derive 3–5 specific, answerable questions from the goal.

**Compare mode:** Establish the options being compared and the criteria to evaluate them against. Suggest criteria the user may not have thought of. For example:
- Trail runners → drop height, stack, lug depth, terrain type, return policy
- Educational courses → syllabus depth, instructor credentials, community, job outcomes, refund policy

In both modes, **proactively surface what the user may be missing** — common blind spots, adjacent topics, prerequisite knowledge, or implications they haven't asked about. For example, if the user asks about home office tax deductions:
- They may not have asked about record-keeping requirements
- They may not know there are two calculation methods
- They may not have considered what changes if they're employed vs self-employed

Ask the user to confirm or adjust the questions and criteria before searching.

### 3. Search

Search for each question using reputable sources. Prioritise in this order:

**Tier 1 — Primary** (always prefer)
- Government and official body websites (.gov, .gov.au, .gc.ca, irs.gov, ato.gov.au, legislation.gov.au, canada.ca, cra-arc.gc.ca, irs.gov, congress.gov, etc.)
- Primary legislation, regulations, and official rulings
- Official specifications and standards bodies (ISO, W3C, RFC, etc.)
- Manufacturer specs and official product pages (for compare mode)

**Tier 2 — Authoritative**
- Established news organisations (Reuters, FT, BBC, AP)
- Peer-reviewed journals and academic publications
- Official documentation from major organisations
- Established review outlets (Wirecutter, Consumer Reports, Trustpilot) (for compare mode)

**Tier 3 — Supporting** (use only to fill gaps)
- Reputable industry publications
- Expert practitioners with verifiable credentials
- Community consensus from specialist forums (e.g. r/ultrarunning for trail shoes)

Discard any source that cannot be traced back to Tier 1 or Tier 2. If a claim only exists in Tier 3, flag it explicitly.

### 4. Synthesise

Write a clear, readable document. Save it to `~/Documents/research/YYYY-MM-DD-<topic>.md` unless the user specified a different location. Create the directory if it doesn't exist.

**Understand mode — use this structure:**

---
## Goal
One sentence: what this research is trying to answer.

## TL;DR
3–5 bullet points. The most important things to know.

## Findings
One section per research question. Plain language — no jargon unless explained.
Flag anything uncertain or contested with ⚠️.

## What we didn't cover
Topics that came up but weren't fully researched. Things worth a follow-up session.

## My notes
*(blank — for you to fill in)*

## Sources
- [Title](url) — Tier 1/2/3 · Published/updated: date · Accessed: date
---

**Compare mode — use this structure:**

---
## Goal
What decision this comparison is supporting.

## Criteria
The factors being evaluated and why each matters.

## Comparison

| | Option A | Option B | Option C |
|---|---|---|---|
| Criterion 1 | | | |
| Criterion 2 | | | |
| Price | | | |
| ⚠️ Watch out | | | |

## Recommendation
Which option and why, given the stated goal. Be direct.

## What we didn't compare
Options or criteria worth a follow-up.

## My notes
*(blank — for you to fill in)*

## Sources
- [Title](url) — Tier 1/2/3 · Published/updated: date · Accessed: date
---

### 5. Discuss

After presenting the findings, invite the user into conversation:

- Does anything need clarifying or expanding?
- Did the research raise new questions?
- Is there a section worth going deeper on?

If the user has follow-up questions, run a new search cycle — don't just reason from what was already found. New questions deserve new evidence.

Throughout the discussion:
- Suggest connections the user may not have made
- Flag if a new question has changed the original goal
- Recommend when it's worth consulting a professional (lawyer, accountant, doctor) rather than relying on research alone
