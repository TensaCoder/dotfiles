---
name: logging
description: Enforce logging level standards in C/C++ and Swift/JS extension code. Use when user writes log calls, asks which level to use, or audits a module for logging consistency. Dont update the log calls and levels for the files which aren't being included for change, only use for current new changes or modifications being made.
mode: true
---

# Logging Standards

Levels are keyword-only and function-call independent. Use whichever logging
macro or function your codebase provides — the level keyword is what matters.

## Behavioural Rules

- **Ask first**: If the severity of a failure is ambiguous (recoverable vs fatal),
  ask before assigning a level — wrong levels degrade observability.
- **CLAUDE.md updates**: If a new subsystem is encountered with unique logging
  patterns, propose adding its examples to the project root CLAUDE.md (not ~/.claude/CLAUDE.md) and ask for confirmation.

---

## Level Reference

| Level | Purpose | Examples |
|---|---|---|
| `Trace` | Internal lifecycle — method entry, object creation, handle acquired | Constructor called, handle opened, buffer allocated |
| `Debug` | State snapshots — only useful when debugging | Buffer sizes, cache contents, config values, handle values |
| `Info` | Key operational events — always visible in monitoring | Extension loaded, policy applied, service started |
| `Warn` | Recoverable failure — system continues | IPC retry, fallback scan path, queue full |
| `Error` | Actual error requiring attention | Syscall failed, handle invalid, parse error |
| `Critical` | Stability or data integrity at risk | Driver unload failed, corruption detected |

## Decision Tree

```
Method entry / constructor / handle acquired?    → Trace
State info only useful when debugging?           → Debug
Key event (load, register, start, policy apply)? → Info
Failed but will retry or system continues?       → Warn
Actual error, operation failed?                  → Error
Stability or data integrity threatened?          → Critical
```

## Common Mistakes

| ❌ Wrong | ✅ Correct |
|---|---|
| `Error` for expected/recoverable failures | `Warn` |
| `Info` for constructor calls | `Trace` |
| `Debug` for key operational events | `Info` |
| `Critical` for non-stability-threatening errors | `Error` |
| `Warn` when operation definitively failed | `Error` |

---

## Examples by Subsystem

### WFP Driver (C)
```c
[Trace]    DlpCallout: ClassifyFn entered, layerId=12
[Debug]    DlpCallout: packet metadata — pid=1234, remoteAddr=10.0.0.1
[Info]     DlpCallout: registered at FWPM_LAYER_ALE_AUTH_CONNECT_V4
[Warn]     DlpCallout: classify result pending — deferring packet
[Error]    DlpCallout: FwpmCalloutAdd0 failed, status=0x80004005
[Critical] DlpCallout: engine handle invalid — WFP subsystem may be corrupt
```

### macOS Network Extension (Swift)
```swift
[Trace]    NEProvider.startProxy() entered
[Debug]    Flow metadata: hostname=acme.com, port=443
[Info]     NetworkExtension: proxy started, tunnel interface utun3
[Warn]     Flow inspection skipped — content inspection queue full
[Error]    NEProvider: failed to open flow: The operation couldn't be completed
[Critical] NetworkExtension: provider crashed — kernel will terminate tunnel
```

### IPC Channel (C++)
```cpp
[Trace]    XpcChannel::Connect() entered
[Debug]    XpcChannel: pending message count=4
[Info]     XpcChannel: connection established to com.acme.agent
[Warn]     XpcChannel: connection interrupted, scheduling reconnect attempt 2
[Error]    XpcChannel: xpc_connection_send_message_with_reply_sync returned error
[Critical] XpcChannel: IPC daemon unreachable — policy enforcement suspended
```

### Browser Extension (TS)
```ts
[Trace]    ContentScript: DOMContentLoaded handler entered
[Debug]    ContentScript: form fields detected { count: 3 }
[Info]     BackgroundWorker: DLP extension initialized, manifest v3
[Warn]     BackgroundWorker: native host response timeout, retrying
[Error]    BackgroundWorker: native messaging port disconnected unexpectedly
[Critical] BackgroundWorker: policy fetch failed — extension operating without policy
```

---

## Sequential Thinking Integration

After installation, invoke by asking Claude to "think through this problem step by step"
or "use sequential thinking to analyze this architecture."
