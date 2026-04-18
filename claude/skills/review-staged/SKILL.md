---
name: review-staged
description: Fast single-pass review of currently staged git changes. Use when user says "review staged changes", "quick review before git commit", or "check my staged diff".
allowed-tools: ["Bash", "Read", "Grep"]
arguments:
  - name: focus
    description: Area to prioritize — bugs, security, memory, performance, readability, all.
    required: false
    default: all
argument-hint: "[focus=all]"
---

# Staged Changes Review

**Focus:** `$focus`

## Behavioural Rules

- **Ask first**: If the purpose of a staged change is unclear from context, ask
  before flagging it as a potential issue.
- **CLAUDE.md updates**: If a new pattern or convention is found, surface it after
  the report and ask for confirmation before writing to the project root CLAUDE.md (not ~/.claude/CLAUDE.md).

---

## Steps

```bash
git diff --staged --name-only
git diff --staged
```

Read full file content for each staged file.

---

## Review Checklist

**Always:**
- Null/dangling pointer dereferences
- Unchecked return values, ignored `[[nodiscard]]`
- Naked `new`/`delete`, RAII violations
- Unwrapped platform handles (`HANDLE`, `fd`, `xpc_object_t`)
- Unsafe C string functions (`sprintf`, `strcpy`, `strcat`)
- Unvalidated input at IPC or extension message boundaries
- Sensitive data not scrubbed before free
- Logging level correctness per CLAUDE.md standards

**If `$focus` includes `performance`:**
- Unnecessary heap allocations on hot paths
- Redundant syscalls, blocking I/O on critical paths
- Lock contention on high-frequency paths

**If `$focus` includes `readability`:**
- Nesting > 3 levels, functions > 60 lines
- Missing `const`, undocumented lock ownership
- Platform types in domain headers

For every issue: explain *why* it is problematic, provide concrete fix, explain
interactions with surrounding code.

---

## Output

```
## Critical Issues
[file:line] Problem: | Explanation: | Suggested Fix:

## Potential Bugs

## Memory / Resource Issues

## Performance Concerns

## Readability / Maintainability

## Positive Observations
```

---

## Sequential Thinking Integration

After installation, invoke by asking Claude to "think through this problem step by step"
or "use sequential thinking to analyze this architecture."
