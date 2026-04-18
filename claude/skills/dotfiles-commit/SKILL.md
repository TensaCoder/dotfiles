---
name: dotfiles-commit
description: Use when making changes to dotfiles and need to stage, commit with auto-generated message, and push to remote
---

# Dotfiles Commit Workflow

## Overview

Streamlines the dotfiles commit workflow: stage changes, preview diffs, generate professional commit message, commit, and push to remote with confirmations at each step.

Eliminates manual git command sequences and ensures consistent commit quality across dotfiles updates.

## When to Use

- After modifying dotfiles config files (`.zshrc`, keybindings, settings, scripts)
- After backing up Claude Code config (`claude/` directory)
- Any dotfiles changes that should be version-controlled and pushed

**NOT for:** Major branch refactors, force pushes, or destructive operations (use manual git for those)

## Workflow

```
1. Stage changes  → Choose what to include
2. Preview diff   → Review before commit
3. Generate msg   → Use commit-message skill
4. Confirm commit → Review message
5. Commit         → Create commit
6. Confirm push   → Final gate before remote
7. Push           → Send to remote
```

## Step-by-Step Guide

### Step 1: Show Current Status
```bash
cd ~/dotfiles
git status --short
```
See what's changed. Identifies files to stage.

### Step 2: Stage Changes Selectively

**Option A - Stage specific paths:**
```bash
git add path/to/file path/to/directory/
git status
```
Use this when only certain changes should be committed now.

**Option B - Stage all changes:**
```bash
git add .
git status
```
Use when all changes should be included.

### Step 3: Preview Staged Changes
```bash
git diff --cached --stat
```
Shows summary. For full diff:
```bash
git diff --cached
```

**ALWAYS review before proceeding.** Catch mistakes before commit.

### Step 4: Generate Commit Message

Run the commit-message skill:
```
Invoke the commit-message skill with the staged changes context
```

The skill generates professional message from your changes. Review for accuracy.

### Step 5: Create Commit
```bash
git commit -m "your message here"
```

Confirm message is correct before executing.

### Step 6: Preview Remote Changes
```bash
git log --oneline origin/main..HEAD
git log --oneline origin/FP-Main-Mac..HEAD
```

Shows what WILL be pushed. Verify it's correct.

### Step 7: Push to Remote

With confirmation:
```bash
git push
```

If branch not tracked:
```bash
git push -u origin <branch-name>
```

## Common Scenarios

### Scenario 1: Claude Config Backup
```bash
# After backup-mem.sh synced memory
cd ~/dotfiles
git add claude/project-claude-md/ claude/config/
git diff --cached --stat
# → Generates message like "chore: claude backup 2026-04-18"
git commit -m "..."
git push
```

### Scenario 2: Dotfiles Configuration Update
```bash
# After editing .zshrc, keybindings, setup scripts
cd ~/dotfiles
git add .
git diff --cached --stat
# → Review changes (should only see expected files)
git commit -m "..."
git push
```

### Scenario 3: Selective Changes
```bash
# Only commit Claude skills, skip zshrc changes
cd ~/dotfiles
git add claude/skills/
git status  # Verify only skills are staged
git diff --cached --stat
git commit -m "..."
git push
```

## Pre-Commit Checklist

Before executing the commit:
- [ ] `git status` shows ONLY the files you want to commit
- [ ] `git diff --cached` looks correct (no unintended changes)
- [ ] Commit message is professional and descriptive
- [ ] You're on the correct branch (`git branch -v`)
- [ ] Remote is the intended destination (`git remote -v`)

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Staged unintended files | Run `git reset` before commit, re-stage carefully |
| Forgot to review diff | Always `git diff --cached` before `git commit` |
| Committed to wrong branch | Use `git reset --soft HEAD~1`, switch branch, re-commit |
| Generic commit message | Use commit-message skill for professional message |
| Pushed without review | Always check `git log origin/branch..HEAD` first |
| Staged too many changes | Use `git reset` and stage incrementally with `git add -p` |

## Troubleshooting

### "nothing to commit, working tree clean"
No changes to stage.
```bash
git status  # Verify nothing changed
```

### "error: src refspec main does not match any"
Branch name mismatch. Check:
```bash
git branch -v     # Current branch
git remote -v     # Remote URL
```

### "Updates were rejected"
Remote is ahead. Pull first:
```bash
git pull --rebase
git push
```

### "Permission denied"
SSH key issue or wrong remote URL. Check:
```bash
git remote -v
ssh -T git@github.com  # Test SSH
```

## Red Flags - STOP Before Pushing

- [ ] Unintended files in diff (e.g., `.env`, credentials)
- [ ] Massive diff (> 100 files) - something went wrong
- [ ] Message is vague ("update", "fix", "changes")
- [ ] You're unsure what will be pushed
- [ ] Branch tracking looks wrong

**If ANY red flag:** Stop, reset, investigate.

```bash
git reset      # Undo staging
git status     # Start over
```

## Integration with Other Skills

This skill is part of a workflow suite:

- **claude-backup**: Runs `backup-mem.sh` then uses this skill to commit
- **commit-message**: Generates professional messages (REQUIRED for Step 4)

**REQUIRED SUB-SKILL:** Use commit-message for generating commit messages from staged changes
