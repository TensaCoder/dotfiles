---
name: claude-backup
description: Use when user asks to backup Claude, save Claude config, sync memory to Obsidian, run backup scripts, or preserve Claude settings and project CLAUDE.md files.
---

# Claude Backup

## Overview

Runs the dotfiles backup scripts, then commits and pushes all resulting changes in the dotfiles repo. The git commit+push is intentional and scoped to this skill only.

## Steps (execute in order)

### 1. Run backup-mem.sh

```bash
bash ~/dotfiles/claude/backup-mem.sh
```

This syncs:
- **claude-mem project memory** → Obsidian vault (`Obsidian/Work/claude-mem/`)
- **Observer sessions** (session history JSONL files)
- **Project CLAUDE.md files** → `~/dotfiles/claude/project-claude-md/`

### 2. Commit any changes in dotfiles

```bash
cd ~/dotfiles
git add claude/project-claude-md/ claude/config/ claude/plugins/
git status
```

If there are staged changes, commit with a timestamp message:

```bash
git commit -m "chore: claude backup $(date '+%Y-%m-%d')"
```

If nothing changed, skip the commit and report "nothing to commit".

### 3. Push to remote

```bash
git push
```

Report the result (pushed, or already up to date).

## Full sequence (copy-paste)

```bash
bash ~/dotfiles/claude/backup-mem.sh && \
  cd ~/dotfiles && \
  git add claude/project-claude-md/ claude/config/ claude/plugins/ && \
  git diff --cached --quiet && echo "Nothing to commit." || \
  git commit -m "chore: claude backup $(date '+%Y-%m-%d')" && \
  git push
```

## When to Run Other Scripts

| Script | When |
|---|---|
| `setup.sh` | Setting up symlinks after adding a new config file |
| `install-plugins.sh` | New machine — installs plugins from dotfiles metadata |
| `restore-projects.sh` | New machine — restores project CLAUDE.md files from manifest |

These are **not** part of the regular backup — run them manually as needed.

## Common Mistakes

- `setup.sh` does not back up — it only manages symlinks
- Always commit `project-claude-md/` to git after backup so the snapshot is versioned
- Check `git status` before committing — only stage backup-related paths, not unrelated changes
