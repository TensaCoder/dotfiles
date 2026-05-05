---
name: pr-context
description: Use when generating PR description sections (Description, What Changed, Impact) for human reviewers or AI code review context. Triggered by "generate PR context", "write PR overview", "create PR description", or before a code review when branch context is needed.
allowed-tools: ["Bash", "Read"]
---

# PR Context Generator

Generates three sections that give human reviewers and AI code reviewers plain-English context for the changes on the current branch.

## Behavioural Rules

- **Description is prose** — never bulleted; 2–4 sentences explaining the *why* and high-level *what*
- **What Changed explains intent** — each bullet answers "why was this changed?", not just "what the diff shows"
- **Component header casing**: ALL CAPS for logical areas (`GLOBAL VARIABLES`, `PARAMETERS`), natural case for code constructs (`Header`, `Implementation`, `CMakeLists.txt`)
- **Impact is consumer-facing only** — internal refactors with no external effect stay out; include "No changes to X" when worth noting
- **Ask before splitting** — if commits span two clearly unrelated concerns, ask whether to write one combined context or two

---

## Steps

### 1. Detect base branch and compute merge base

```bash
# Detect tracked default branch
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

# Fallback: try common names in order
if [ -z "$BASE" ]; then
  for candidate in main master develop; do
    if git rev-parse --verify "origin/$candidate" >/dev/null 2>&1; then
      BASE=$candidate
      break
    fi
  done
fi

# If still empty, ask the user which base branch to use
echo "Base branch: $BASE"

MERGE_BASE=$(git merge-base HEAD "origin/$BASE")
echo "Merge base: $MERGE_BASE"
```

If no base branch can be determined, ask the user before proceeding.

### 2. Gather commit and diff data

```bash
# Commit list (no merges — they duplicate information)
git log --no-merges --oneline $MERGE_BASE..HEAD

# Full commit messages for intent context
git log --no-merges $MERGE_BASE..HEAD

# File-level change summary
git diff $MERGE_BASE..HEAD --stat

# Full diff (use per-file for large diffs — see below)
git diff $MERGE_BASE..HEAD
```

**For large diffs** (>500 lines changed or >20 files): read the `--stat` output first, then fetch individual file diffs in order of most-changed files:
```bash
git diff $MERGE_BASE..HEAD -- <path/to/file>
```
Skip auto-generated files (`.lock`, `*.min.js`, generated protobuf, vendored deps).

### 3. Analyse and group

Group changed files into logical components:
- By subsystem (e.g. "Extension build stages", "Upload logic")
- By file (when each file represents a distinct concern, e.g. `Header`, `Implementation`, `CMakeLists.txt`)
- By concern (e.g. "PARAMETERS", "GLOBAL VARIABLES") when multiple files share a theme

### 4. Write output (see format below)

---

## Output Format

```
Description
[2–4 sentences of prose. Explains the problem being solved, the approach taken, and
any key design decisions. Plain English — no ticket references, no jargon.]

What Changed:

LOGICAL AREA (optional: which file or stage):
[optional one-line framing sentence]
- What changed and why this specific change was needed
- Follow-on detail if the change has multiple parts

Natural Case File or Component Name (filename if code construct):
- What changed and why

Impact

- Consumer-facing consequence (broken paths, API changes, new requirements)
- "No changes to X" if worth explicitly noting
```

---

## Examples

### Example A — build pipeline

```
Description
Introduces even/odd patch version parity: one PREPARE_RELEASE_BUILD run reads the
manifest's last-shipped odd version (e.g. 3.2.25) and automatically derives
debugBuildVersion (3.2.26, even) and releaseBuildVersion (3.2.27, odd). Removes
the Test/ and Prod/ Artifactory path prefixes so all builds land under
{branch}/{version}/. PROD_BUILD is simplified to config-file generation only.

What Changed:

GLOBAL VARIABLES (Jenkinsfile top):
- Replaced single fullBuildVersion with debugBuildVersion and releaseBuildVersion globals
- Added block comment documenting the even/odd parity convention

PARAMETERS:
- Removed APP_ID (single prod ID); added APP_ID_DEBUG and APP_ID_RELEASE (one per parity)
- Updated descriptions for BUILD_UNUGLIFIED_UNSIGNED and PREPARE_RELEASE_BUILD to reflect new semantics

UPLOAD ALL ARTIFACTS STAGE:
- PREPARE_RELEASE_BUILD path now does two-pass upload: pass 1 for debug artifacts under
  {branch}/{debugBuildVersion}/, pass 2 for release artifacts under {branch}/{releaseBuildVersion}/
- Normal CI path: single pass; Test/ prefix removed from all Artifactory paths

Impact

- PREPARE_RELEASE_BUILD now produces two Artifactory version folders per run instead of one;
  downstream consumers (epm-f1e, epw-f1e) must be updated before the new paths are live
- Normal CI artifact path changes from Test/{branch}/{version}/ to {branch}/{version}/ — existing
  CI consumers reading from Test/ will break until their BemLib.groovy is updated
- PROD_BUILD parameter APP_ID replaced by APP_ID_DEBUG + APP_ID_RELEASE; any Jenkins job
  configuration using APP_ID must be updated
```

### Example B — bug fixes

```
Description
Three independent bugs caused incorrect registry writes, a process crash, and
non-zero exit on valid edge-case configs. All three are fixed with minimal,
targeted changes to the stale-extension detection logic, the config parser,
and both platform adapters.

What Changed:

FALSE-POSITIVE STALE EXTENSION DELETION (chrm_ext_sts_json_mgr_win.cpp, chrm_ext_sts_key_mgr_win.cpp):
- removeStaleExtensions() used update_url alone to identify stale entries, deleting
  unrelated third-party extensions sharing the standard Chrome/Edge CDN URL
- Fix: added early-exit guard — stale detection is skipped when the target URL starts
  with https://; only local file-based URLs are unambiguous enough for URL-based detection

CRASH ON DISABLED ACTION WITH NO ExtensionId (bem_cfg_parser.cpp):
- Parser called requireNodeValue("ExtensionId") unconditionally, throwing std::runtime_error
  when action resolved to DISABLED and no ExtensionId was present
- Fix: added pre-check for all three browsers — if action is DISABLED and ExtensionId is
  absent/empty, log a warning and skip; requireNodeValue is never reached

FATAL EXIT ON EMPTY EXTENSION CONFIG (win_adapter.cpp, macos_adapter.cpp):
- Both platform adapters returned false when extensionConfigs was empty after parsing,
  causing BEM to exit non-zero even for a valid "nothing to do" scenario
- Fix: downgraded from EPX_ERROR + return false to EPX_WARN and continue

Impact

- Third-party extensions with CDN URLs no longer deleted during BEM install/update operations
- BEM no longer crashes on Disabled configs missing ExtensionId
- BEM exits cleanly (exit 0) when all config entries resolve to no-op
- No changes to public APIs or registry schema
```
