---
name: software-architecture
description: Apply Clean Architecture principles to C/C++ DLP endpoint systems or any other systems and projects. Use when designing module boundaries, platform abstraction layers, policy engine architecture, or reviewing architectural decisions. NOT for general coding questions.
mode: true
arguments:
  - name: layer
    description: Layer in focus — core, platform, ipc, driver, extension, all.
    required: false
    default: all
  - name: platform
    description: Target platform — windows, macos, both.
    required: false
    default: both
argument-hint: "[layer=all] [platform=both]"
---

# Software Architecture — C/C++ DLP Endpoint

**Layer:** `$layer`
**Platform:** `$platform`

## Behavioural Rules

- **Ask first**: If the scope of a design question spans multiple layers and the
  right boundary is unclear, ask before proposing a structure.
- **CLAUDE.md updates**: If a new architectural decision is made during this session,
  propose adding it to the project root CLAUDE.md (not ~/.claude/CLAUDE.md) and ask for confirmation before writing.

---

## Layer Model

```
┌─────────────────────────────────────────┐
│  Browser Extension (JS/TS, Swift)       │  ← Extension layer
├─────────────────────────────────────────┤
│  UI / Management Console                │  ← Presentation layer
├─────────────────────────────────────────┤
│  IPC / Agent Communication              │  ← IPC layer
├─────────────────────────────────────────┤
│  Policy Engine / Content Inspection     │  ← Core layer (platform-independent)
├─────────────────────────────────────────┤
│  Platform Abstraction (interfaces)      │  ← Platform interface layer
├─────────────────────────────────────────┤
│  Platform Impl: WFP / NetworkExtension  │  ← Platform layer
│  File Monitor / ESF / DriverKit         │
└─────────────────────────────────────────┘
```

---

## Layer Rules

### Core Layer
- Zero platform API calls — must compile on any target
- All platform interaction through abstract interfaces (`IFileMonitor`, `INetworkInterceptor`)
- No `#ifdef _WIN32` or `#ifdef __APPLE__` in core headers
- Policy evaluation deterministic and unit-testable without a running OS

### Platform Abstraction Layer
- Defines interfaces the core layer depends on
- One concrete implementation per platform — `_win.cpp`, `_mac.mm`
- Platform types (`HANDLE`, `pid_t`) never cross this boundary

### IPC Layer
- All schemas versioned
- Messages validated on both ends before processing
- IPC failure must not suspend enforcement — fail-safe policy applies
- macOS: prefer low-level `xpc_connection_t` over `NSXPCConnection`
- Windows: Named Pipes for userspace, shared ring buffer for kernel↔user

### Driver / Kernel Layer (C only)
- No C++ exceptions, no STL, no heap from driver context
- All memory from lookaside lists or non-paged pool with explicit tracking
- Every allocation has a matching free on all exit paths
- IRQL awareness — document IRQL level for each function

### Extension Layer
- Content scripts: collect and forward only — no policy evaluation
- All policy evaluation in background service worker or native host
- Messages schema-validated between content script and background
- Safari: all privileged operations owned by Swift host app

---

## Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Classes | PascalCase | `ContentInspector`, `WfpCalloutDriver` |
| Functions | camelCase | `inspectPayload()`, `registerCallout()` |
| Constants | `k`-prefix | `kMaxBufferSize`, `kDefaultTimeout` |
| Members | `m_` prefix | `m_policyCache`, `m_hPipe` |
| Platform files | `_win.cpp` / `_mac.mm` | `FileMonitor_win.cpp` |
| Interfaces | `I`-prefix | `IFileMonitor`, `IContentScanner` |

---

## Anti-Patterns

- Policy logic in content scripts or UI layer
- Platform API calls in policy engine
- `HANDLE` / `pid_t` in core domain headers
- Synchronous IPC calls on main thread
- Blocking syscalls without timeout in inspection hot path
- `sprintf`, `strcpy` anywhere
- Naked `new`/`delete` for resource-owning objects

---

## Quality Checklist

- [ ] No platform types in core/domain headers
- [ ] All `#ifdef` blocks in `_win.cpp` / `_mac.mm` files
- [ ] Every interface has both Windows and macOS implementations
- [ ] IPC schemas versioned
- [ ] All handles RAII-wrapped
- [ ] No naked `new`/`delete`
- [ ] Logging uses correct levels per CLAUDE.md
- [ ] No synchronous blocking calls on main/UI thread

---

## Sequential Thinking Integration

After installation, invoke by asking Claude to "think through this problem step by step"
or "use sequential thinking to analyze this architecture."
