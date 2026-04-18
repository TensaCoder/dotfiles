# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A hybrid repository for Forcepoint's DLP browser extensions and their native host manager:
- **Browser Extensions** (Chrome/Firefox): Manifest V3 JavaScript extensions that enforce DLP policy in-browser via content scripts, service workers, and declarativeNetRequest rules.
- **BrowserExtensionManager (BEM)**: A C++17 cross-platform CLI (`bem`) that installs, uninstalls, and manages browser extension lifecycle on macOS and Windows via registry, plists, configuration profiles, and pluginkit.

These two components have **completely separate build systems** and should be treated as independent projects sharing a repo.

## Build & Test Commands

### Browser Extensions (JavaScript)

```bash
# Install dependencies
make install-deps        # or: npm install

# Run unit tests (Jest, jsdom environment)
make unit-test           # or: npm run test

# Run a single test file
npx jest __tests__/hostMatchUtil.test.js

# Lint
npm run lint             # ESLint check
npm run lint:fix         # ESLint auto-fix

# Build (uglify Chrome extension)
make build

# Clean
make clean
```

### BrowserExtensionManager (C++17 / CMake)

All BEM commands run from `BrowserExtensionManager/`:

```bash
# macOS
mkdir -p build && cd build
conan install .. --build missing --profile epx-mac-apple-clang -if .
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release -- -j$(sysctl -n hw.ncpu)

# Windows (PowerShell)
mkdir build -ErrorAction SilentlyContinue; cd build
conan install .. --build missing --profile epx-windows-vs2015 -s build_type=Release -s arch=x86_64 -if .
cmake .. -G "Visual Studio 14 2015 Win64"
cmake --build . --config Release -- /m

# Run all C++ tests (from build/)
ctest --output-on-failure

# Run a single C++ test
./test_configuration --gtest_filter="*TestName*"

# Post-build checks (naming + clang-format)
cmake --build . --target post_build_checks
```

Conan requires org profiles from `epx-conan-config`. Bootstrap with:
```bash
pip install -r requirements.txt
conan config install --type=git https://github.cicd.cloud.fpdev.io/endpt/epx-conan-config
```

## Architecture

### Browser Extensions

Both Chrome and Firefox share nearly identical JS code. Key scripts:

| File | Role |
|------|------|
| `background.js` | Service worker — DLP policy enforcement, native messaging with F1E agent |
| `content.js` | Content script injected at document_start |
| `nw-hooking-page.js` | Network request hooking in MAIN world |
| `nw-hooking-content.js` | Content script bridge for network hooking |
| `rules.json` | declarativeNetRequest blocking rules |

Native messaging uses `com.forcepoint.usersessionidprovider` to get Windows session IDs from `UserSessionIDProvider.exe`.

### BrowserExtensionManager (BEM) — Strategy Coordinator Pattern

Six-layer architecture:

1. **Application** — `app/main.cpp`, CLI entry point
2. **Manager Facades** — `ChromiumExtensionManager`, `MozillaExtensionManager`, `WebKitExtensionManager`
3. **Strategy Coordinators** — Platform-specific orchestrators per browser (e.g. `ChromiumCoordinator_Win`, `WebKitCoordinator_Mac`)
4. **Strategy Implementations** — Isolated deployment methods (ForceList, ExtSettings, registry, plist, profiles, pluginkit)
5. **Platform Services** — `src/core/platform/` with `mac/` and `win/` subdirectories
6. **Utilities** — `OperationResult`, logging (`EPX_*` macros via spdlog), `IBrowser` interface

Source layout under `BrowserExtensionManager/`:
```
src/
├── bem/                    # Core BEM library
│   ├── cfg/               # XML config parsing
│   ├── chrm/              # Chromium strategies (cross-platform + mac/win)
│   ├── moz/               # Mozilla strategies (cross-platform + mac/win)
│   └── wk/                # WebKit/Safari strategies (macOS only)
├── core/
│   ├── logger/            # spdlog wrapper (EPX_* macros)
│   ├── json/              # rapidjson wrapper
│   └── platform/          # OS abstraction layer
│       ├── mac/           # macOS: plist, HSW converter, pluginkit
│       └── win/           # Windows: registry, HSW converter
└── app/main.cpp
```

## Key Conventions

- **Logging**: Use `EPX_*` macro family (`EPX_TRACE`, `EPX_DEBUG`, `EPX_INFO`, `EPX_WARN`, `EPX_ERROR`, `EPX_CRITICAL`). Avoid bare `ERROR(...)` — it collides with platform headers.
- **Platform isolation**: Platform files suffixed `_mac.cpp`/`_mac.mm`/`_win.cpp`. Platform types must not appear in domain headers.
- **C++ dependencies**: spdlog 1.7.0, rapidxml 1.13, rapidjson 1.1.0, gtest 1.11.0. Managed via Conan with `cmake` generator. `conanbuildinfo.cmake` must exist before CMake configure.
- **JS formatting**: Prettier (120 char, 2-space indent, single quotes, semicolons).
- **C++ formatting**: clang-format (LLVM base, Allman braces, 4-space indent, 100-col limit).
- **Compiler warnings as errors**: Clang: `-Wall -Wextra -Wpedantic -Wconversion -Wshadow -Werror`. MSVC: `/W4 /WX /permissive-`.
- **Uglification caveat**: `mangle.properties: true` breaks the extension. Never enable it.

## CI/CD

Jenkins pipeline (Jenkinsfile) builds macOS + Windows matrix. Key parameters:
- `BUILD_UNUGLIFIED_UNSIGNED` — debug-readable JS build
- `BUILD_MAC` / `BUILD_WIN` — platform toggles
- `PREPARE_RELEASE_BUILD` — version management (GA vs IB)

BEM version is injected via `-DBEM_VERSION_*` CMake flags. Extension version lives in `manifest.json`.

Artifacts go to Artifactory under the F1E repo. Firefox build is automated by `Build.py`.

## Branching

- Main integration branch: `develop`
- Feature branches: `UEP-*` (Jira ticket ID)
