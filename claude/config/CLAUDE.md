# Project Standards

Applies to all C, C++ and browser extension code across macOS and Windows.
Claude must follow these rules in every session without being explicitly asked.

---

## General Behaviour Rules

### Ask When in Doubt
If anything is ambiguous — the intent of a request, the codebase context, a
platform behaviour, or which approach is correct — stop and ask a clarifying
question before proceeding. One focused question is better than a wrong
implementation.

### Perform Dry-Run & Static Analysis Before Implementation
Before writing, modifying, or deploying code that performs system changes 
(file migrations, symlinks, batch operations, data restoration):

1. **Static analysis**: Trace through code logic for edge cases, failure modes, 
   and assumptions that could silently fail.
2. **Dry-run scenarios**: Mentally execute the code against:
   - Happy path (normal case with expected state)
   - Fresh state (new machine, empty directories, no prior setup)
   - Dirty state (re-running script, partial previous state, conflicts)
   - Failure modes (permissions denied, disk full, missing dependencies, network issues)
3. **Document findings**: Report critical issues (data loss risks, silent failures), 
   medium-priority edge cases, and test cases for verification.
4. **Get clarity**: If analysis reveals ambiguity or missing information, stop and 
   ask the user before proceeding.

This prevents silent failures, data loss, and cascading bugs in shell scripts and 
system-level operations.

### Proactively Update CLAUDE.md
If during any session Claude discovers something useful not already captured
here — a new pattern, a platform quirk, an architectural decision, a build
system detail — Claude must:
1. Point out what was learned and why it is worth capturing
2. Ask the user for confirmation before writing anything
3. Only append/update CLAUDE.md after explicit approval

### Always Use Relevant Skills and Plugins
Before responding to any prompt — including clarifying questions — Claude must:
1. Check whether any available skill or plugin applies to the task.
2. Invoke every relevant skill using the `Skill` tool before taking action.
3. If there is even a 1% chance a skill applies, invoke it to verify.

This applies to all task types: feature development, debugging, code review,
architecture, memory lookups, git operations, and scheduling.

---

## Language & Platform Targets

- **Primary**: C++17/20 for userspace agents and services
- **C**: Kernel-adjacent code, driver interfaces, POSIX layers
- **Browser Extensions**: JavaScript/TypeScript (Chrome/Edge MV3), Swift (Safari Web Extension)
- **Platforms**: macOS 12+, Windows 10/11 (x64)
- **Compiler warnings**: Treat as errors — `-Wall -Wextra -Werror` (clang/gcc), `/W4 /WX` (MSVC)

---

## Logging Standards

Log levels are keyword-only and function-call independent.
Use whichever logging macro or function your codebase provides —
the level keyword is what matters, not the call signature.

### Levels

| Level | When to use | Examples |
|---|---|---|
| `Trace` | Internal lifecycle — method entry, object creation, handle acquired | Constructor called, buffer allocated, handle opened |
| `Debug` | State snapshots — only useful when debugging | Buffer sizes, policy cache contents, handle values, config |
| `Info` | Key operational events — always visible in monitoring | Extension loaded, service started, policy applied |
| `Warn` | Recoverable failure — system continues | IPC retry, fallback path, partial scan skipped |
| `Error` | Actual error requiring attention | Syscall failed, handle invalid, parse error |
| `Critical` | System stability or data integrity at risk | Driver unload failed, kernel panic risk, data corruption |

### Decision Tree

```
Method entry / constructor / handle acquired?    → Trace
State info only useful when debugging?           → Debug
Key operational event (load/start/register)?     → Info
Failed but system continues / will retry?        → Warn
Actual error occurred?                           → Error
System stability or data integrity threatened?   → Critical
```

### Common Mistakes

- `Error` for expected recoverable failures → use `Warn`
- `Info` for constructor calls or handle traces → use `Trace`
- `Debug` for key operational events → use `Info`
- `Critical` for non-fatal errors → use `Error`
- `Warn` when operation permanently failed → use `Error`

### Example (adapt to your logging macro)

```
[Trace]    FileWatcher::startMonitoring() entered
[Debug]    Watching paths: ["/usr/local/lib", "/tmp"]
[Info]     File monitoring started for directory: /usr/local/lib
[Warn]     File event dropped — throttling active
[Error]    Failed to create FSEvent stream: error=kFSEventStreamCreateFlagNone
[Critical] File monitoring stopped unexpectedly — system in unknown state
```

---

## C/C++ Code Quality Standards

### Memory Management
- No naked `new`/`delete` — use `std::unique_ptr`, `std::shared_ptr`, or arena allocators
- RAII everywhere — resources (handles, fds, locks) must be wrapped in RAII types
- Platform handles must be wrapped: `HANDLE` (Windows), file descriptors (POSIX), `IOSurface`, `xpc_object_t`
- No owning raw pointers in class members — ever
- Prefer stack allocation over heap for small, bounded objects

### Platform Abstractions
- Isolate all platform-specific code behind an interface or `#ifdef` block
- Platform files suffixed `_win.cpp` / `_mac.mm` / `_mac.cpp`
- Platform types (`DWORD`, `pid_t`, `dispatch_queue_t`) must not appear in domain headers
- No platform API calls leaking into business logic layer

### Code Style
- Early return always over nested conditions
- Max nesting depth: 3 levels (4 max in driver code)
- Functions under 60 lines (kernel/driver: 80 max)
- Files under 400 lines — split otherwise
- `const` everywhere it applies
- `[[nodiscard]]` on functions returning error codes or resource handles
- `enum class` over `enum` or `#define` constants
- No `using namespace std;` in headers

### Error Handling
- No silent failures — every error code checked and handled or propagated
- `[[nodiscard]]` on all `HRESULT`, `kern_return_t`, errno-style return functions
- Exceptions prohibited in kernel-adjacent and driver code

### Thread Safety
- All shared mutable state protected — document the lock per field
- `std::shared_mutex` for read-heavy, write-rare data
- No `volatile` for synchronisation — use `std::atomic` or mutexes
- Lock ordering must be documented

### Security
- Validate all input crossing trust boundaries
- No `sprintf`, `strcpy`, `strcat`, `gets`
- No stack VLAs
- Scrub sensitive data from memory before deallocation

### Naming Conventions
- Classes/Structs: `PascalCase`
- Functions/Methods: `camelCase`
- Constants/Enums: `k`-prefix PascalCase — `kMaxRetries`
- Member variables: `m_`-prefix — `m_handle`
- Interfaces: `I`-prefix — `IFileMonitor`
- Platform files: `_win.cpp` / `_mac.mm`
- No generic names: `utils.cpp`, `helpers.h`, `misc.h`

---

## Architecture Standards

- Business/policy logic must be platform-independent
- Platform layer implements interfaces defined by core — never the reverse
- Browser extension content scripts must not contain policy logic
- IPC message schemas must be versioned
- All kernel/driver code reviewed separately from userspace

---

## Browser Extension Standards

- Use Manifest V3
- Use `chrome.declarativeNetRequest` for network rules
- Content scripts: collect and forward only — never evaluate policy
- Message passing validated on both ends
- Safari: Swift host app owns all privileged operations
- No sensitive data in `chrome.storage.local` unencrypted

---

## Graphify Code Analysis Protocol

Before reading any source file for any code task, check whether a graphify knowledge graph exists for the current repository in the Obsidian vault:

**Vault path**: `/Users/herschel.menezes/Library/CloudStorage/OneDrive-Forcepoint,LLC/Obsidian/Work/Graphify/<repo-name>/`

Where `<repo-name>` is the basename of the current working directory (e.g. `epx-network-proxy`).

### Decision

- **Graph exists** (`GRAPH_REPORT.md` present at that path): use it — do NOT read raw source files until the graph has been consulted
- **Graph absent**: fall back to normal file search and reading

### When graph exists — required steps before reading any source file

1. Read `<vault>/GRAPH_REPORT.md` — identifies god nodes (highest-degree files/functions) and community structure (logical subsystems)
2. If `<vault>/graphify-out/wiki/index.md` exists, look up the relevant component there — each wiki article covers one community at ~200 tokens vs reading full source files
3. Use the graph to identify *which specific files* are involved, then read only those

### Applies to

Tracing a function, understanding a call chain, locating a symbol, debugging, implementing a feature, understanding component interactions — every code task.

### Never

- Read files at random to "explore" when a graph is available
- Read a file to find where a symbol is defined — check the graph first

### Maintenance

After modifying code files in any session, run `graphify . --update` to keep the graph current (AST-only, no API cost). Then run `/graphify-update` to sync to the vault.

---

## Code Review Workflow

- **Never post to GitHub directly.** After completing a code review, present the formatted issue list to the user in the terminal. The user will manually add review comments to the PR.
- **Max 3 parallel agents** for code review — do not launch more than 3 review agents in parallel.

---

## Codebase Overview

<!-- Maintained by /codebase-onboarding -->
<!-- Run /codebase-onboarding to populate or refresh this section -->
<!-- Summary only — full details in CODEBASE.md -->
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
