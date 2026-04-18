---
name: git-commit
description: Generate a professional commit message from staged C/C++ or extension changes without type/scope prefix. Use when user says "generate commit message", "write a commit", "commit my changes", or asks about commit message format.
allowed-tools: ["Bash", "Read"]
arguments:
  - name: type
    description: Commit type — feat, fix, chore, refactor, perf, docs, test, ci. Inferred from diff if omitted. Not added to commit title.
    required: false
  - name: scope
    description: Scope — e.g. file-watcher, policy-engine, wfp-driver, network-ext, safari-ext, ipc. Inferred if omitted. Not added to commit title.
    required: false
  - name: breaking
    description: Set true if this is a breaking change. Appends BREAKING CHANGE footer.
    required: false
    default: false
argument-hint: "[type] [scope] [breaking=false]"
---

# Git Commit Message Generator

**Type:** `$type` (inferred if not provided)
**Scope:** `$scope` (inferred from file paths if not provided)
**Breaking:** `$breaking`

## Behavioural Rules

- **Ask first**: If staged changes span multiple concerns that could reasonably
  be split into separate commits, ask the user whether to consolidate or separate.
- **CLAUDE.md updates**: If the diff reveals a new subsystem, pattern, or convention
  not in CLAUDE.md, mention it after generating the message and ask for confirmation to be added in the project root CLAUDE.md (not ~/.claude/CLAUDE.md) and update it.

---

## Steps

```bash
git diff --staged
git diff --staged --name-only
```

Determine intent: bugfix, feature, refactor, platform port, config, cleanup.
Infer `$type` and `$scope` if not provided.

---

## Output

```
Commit Title:
<imperative summary, max 72 chars>

Commit Description:
- Main purpose of the change
- Key modifications made
- Platform(s) affected (Windows / macOS / both) if relevant
- RAII / memory safety improvements if applicable
- IPC contract or API changes if applicable
- Edge cases or error paths addressed
```

If `$breaking == true`:
```
BREAKING CHANGE: <what breaks and migration path>
```

Rules: imperative mood, no filenames unless essential, no diff repetition, max 72 chars title. No type/scope prefix in title.

---

## Examples

```
Commit Title:
Prevent resource leak in file monitoring service

Commit Description:
- Prevent resource leak when file monitoring initialization fails
- Ensure Windows handles are properly closed on early return paths
- Introduce RAII wrapper for handle management
- Improve error handling when watcher setup fails
```

---

## Sequential Thinking Integration

After installation, invoke by asking Claude to "think through this problem step by step"
or "use sequential thinking to analyze this architecture."
