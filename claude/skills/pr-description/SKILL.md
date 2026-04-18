---
name: pr-description
description: Use when user asks to generate a PR title and description, write a pull request description, or summarize changes for a PR. Outputs title and description only — does NOT create or open a PR.
allowed-tools: ["Bash", "Read"]
---

# PR Title and Description Generator

## Behavioural Rules

- **Ask first**: If the diff spans multiple unrelated concerns, ask whether to write one PR description or split.
- **Title style**: Imperative mood, no colon, no type/scope prefix, max 72 chars. Phrase as what the PR accomplishes, not what was done (e.g. "Improve X" not "Improved X").
- **Description**: Prioritise clarity for the reviewer. Do not artificially shorten — use subsections and detail wherever it aids understanding.

## Steps

```bash
git diff main...HEAD --stat
git diff main...HEAD
git log main...HEAD --oneline
```

Determine the intent and group changes into logical themes.

## Output Format

```
PR Title:
<imperative summary, max 72 chars, no colon, no type prefix>

PR Description:

## Why
- <reason 1>
- <reason 2>
- ...

## Changes

### <Logical group or component name>
- <what changed and why — enough detail for the reviewer to understand>
- ...

### <Next group>
- ...
```

## Rules

- Title: imperative mood, no colon, no `feat:`/`fix:` prefix, max 72 chars
- Description: bullet points only, no paragraphs
- Group changes into named subsections when there are multiple components
- Explain *why* each change was made, not just what changed
- Do not truncate detail — if a change needs three bullets to explain, use three
- Do not add a "Testing" section unless the diff includes test changes

## Example

```
PR Title:
Improve Claude Code dotfiles backup skill scripts and config updates

PR Description:

## Why
- Backup script lacked observer-session support
- setup.sh was missing commands/ directory symlinking
- No skill existed to trigger backups, commit, and push in one step
- git-commit skill name was misleading — it only generates message text

## Changes

### New skill — claude-backup
- Runs backup-mem.sh to sync claude-mem memory and observer sessions
- Stages only backup-related paths to avoid committing unrelated work
- Commits with a date-stamped message and pushes to remote
- Git commit and push are scoped to this skill only

### Renamed skill — git-commit → commit-message
- Renamed directory and updated name/description in frontmatter
- Description now explicitly states it outputs text only and does not run git commit

### backup-mem.sh
- Added observer-session sync (claude-mem session history JSONL files)
- Improved project-label extraction from encoded directory names

### setup.sh
- Added commands/ directory symlinking
- Added plugin metadata snapshot for installed_plugins.json and blocklist.json
```
