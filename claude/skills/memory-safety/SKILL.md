---
name: memory-safety
description: Audit C/C++ code for memory safety — leaks, UAF, buffer overflows, RAII violations, unsafe functions. Use when writing C/C++ code, reviewing a memory-intensive module, asking about smart pointers, or investigating a crash or leak.
allowed-tools: ["Bash", "Read", "Grep"]
arguments:
  - name: target
    description: File or directory to audit. Audits staged diff if omitted.
    required: false
argument-hint: "[target]"
---

# Memory Safety Audit

**Target:** `$target`

## Behavioural Rules

- **Ask first**: If ownership semantics of a variable are unclear from context
  (shared vs unique vs borrowed), ask before flagging as a violation.
- **CLAUDE.md updates**: If a new handle type or RAII pattern should be
  standardised across the codebase, propose adding it to CLAUDE.md and ask
  for confirmation before writing (project root CLAUDE.md, not ~/.claude/CLAUDE.md).

---

## Checklist

### Ownership & Lifetime
- [ ] Naked `new`/`delete` — flag every instance
- [ ] Raw owning pointers in class members
- [ ] Dangling pointers, use-after-free, double-free
- [ ] Return of pointer/reference to local variable

### Platform Handles (must be RAII-wrapped)

| Handle | Platform | RAII Pattern |
|---|---|---|
| `HANDLE` | Windows | `wil::unique_handle` or custom guard |
| `SOCKET` | Windows | `wil::unique_socket` |
| `int` (fd) | POSIX/macOS | Custom `FdGuard` |
| `xpc_object_t` | macOS | Guard calling `xpc_release` |
| `IOSurface` | macOS | Guard calling `CFRelease` |
| `dispatch_queue_t` | macOS | Retain/release guard |

### Buffer Safety
- [ ] `memcpy`/`memset`/`memmove` — size argument correct
- [ ] `sprintf`, `strcpy`, `strcat`, `gets` — flag all, replace with bounded variants
- [ ] Stack VLAs — prohibited
- [ ] Array index from external input — bounds checked

### Error Path Leaks
- [ ] Every early return / throw — handles released
- [ ] Exception thrown after resource acquired but before RAII guard set up
- [ ] C `goto cleanup` — cleanup label reached on all paths

### Concurrency
- [ ] Shared mutable state without mutex
- [ ] `volatile` used for sync instead of `std::atomic`
- [ ] Lock ordering documented; deadlock paths identified


---

## Output

```
## 🔴 Critical Memory Issues
[file:line] Issue | Root Cause | Fix

## 🟠 Resource Leaks
[file:line] Resource | Leak Path | RAII Fix

## 🟡 Unsafe Operations
[file:line] Function | Risk | Replacement

## ✅ Safe Patterns Observed
```

---

## Sequential Thinking Integration

After installation, invoke by asking Claude to "think through this problem step by step"
or "use sequential thinking to analyze this architecture."
