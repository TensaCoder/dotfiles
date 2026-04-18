---
name: review-pr
description: Multi-agent pull request review posting inline GitHub comments. Use when user says "review this PR", "check pull request #N", or asks for code review on a GitHub pull request.
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Task"]
arguments:
  - name: pr_number
    description: PR number to review. Inferred from current branch if omitted.
    required: false
  - name: aspects
    description: Comma-separated aspects — security, bugs, memory, quality, contracts, tests, platform, all.
    required: false
    default: all
  - name: strict
    description: Set false to surface high-confidence issues (increases threshold from 60 to 80).
    required: false
    default: true
argument-hint: "[pr_number] [aspects=all] [strict=true]"
---

# Pull Request Review

**PR:** `$pr_number`
**Aspects:** `$aspects`
**Strict:** `$strict`

> Skip `spec/` and `reports/` unless in `$aspects`.
> Post inline comments only — no summary reports. Each comment must add real value.

---

## Behavioural Rules

- **Ask first**: If the PR description is missing and intent is unclear, or a
  change looks like it could be intentional or a bug, ask before flagging.
- **CLAUDE.md updates**: If the PR reveals patterns or decisions not in CLAUDE.md,
  surface them after the review and ask for confirmation before writing (project root CLAUDE.md, not ~/.claude/CLAUDE.md).

---

## Phase 1: Preparation

1. Is PR closed or draft? → abort, notify user.
2. `git diff origin/master...HEAD --stat` (swap to `main` if needed)
3. Collect instruction file paths: `CLAUDE.md`, `AGENTS.md`, `**/constitution.md`,
   `README.md` in modified dirs.
4. Summarize each changed file: types, complexity, affected functions/classes/structs.
5. If PR has no description → auto-generate and post a concise one.

---

## Phase 2: Single-Agent Review

Launch **1 Sonnet agent** to review all applicable aspects from `$aspects` sequentially:

The agent must cover each applicable concern below in order, skipping those not relevant to the diff:

| Concern | When to review |
|---|---|
| Security | Non-cosmetic code/config changes |
| Bugs | Non-cosmetic code/config changes |
| Memory safety | Any C/C++ changes |
| Code quality | Any code changes |
| Contracts | Type, API, IPC schema changes |
| Test coverage | Test files changed |
| Platform compatibility | Platform files or `#ifdef` blocks changed |

The agent works through each applicable concern one at a time and collects all findings before scoring.

---

## Phase 3: Confidence & Impact Scoring

**Impact:** 0–20 Low (never post) | 21–40 Med-Low | 41–60 Med | 61–80 High | 81–100 Critical

**Filter thresholds** (subtract 15 if `$strict == true`):

| Impact | Min Confidence |
|---|---|
| 81–100 | 50 |
| 61–80 | 65 |
| 41–60 | 75 |
| 21–40 | 85 |
| 0–20 | Never post |

Re-run eligibility check before posting.

---

## Phase 4: Post Inline Comments

**Preferred**: `mcp__github_inline_comment__create_inline_comment`
**Fallback**: `gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews` (multi) or `/comments` (single)

```
🔴/🟠/🟡 [Critical/High/Medium]: [Brief description]
Evidence: [what was observed and consequence if unfixed]
```suggestion
[corrected code]
```
```
No issues found → report to user only, post nothing.

After the review — if anything worth adding to CLAUDE.md was found, surface it
and ask for confirmation before writing (project root CLAUDE.md, not ~/.claude/CLAUDE.md).

---

## Sequential Thinking Integration

After installation, invoke by asking Claude to "think through this problem step by step"
or "use sequential thinking to analyze this architecture."
