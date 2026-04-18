#!/usr/bin/env bash
# install-plugins.sh — Add Claude Code marketplaces and reinstall all plugins.
#
# Run this on a new machine AFTER setup.sh has been run.
# Reads the plugin list from dotfiles/claude/plugins/installed_plugins.json
# and reinstalls each one from its marketplace.
set -euo pipefail

DOTFILES_CLAUDE="$(cd "$(dirname "$0")" && pwd)"
PLUGINS_JSON="$DOTFILES_CLAUDE/plugins/installed_plugins.json"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}  →${NC} $*"; }
ok()      { echo -e "${GREEN}  ✓${NC} $*"; }
warn()    { echo -e "${YELLOW}  ⚠${NC} $*"; }
err()     { echo -e "${RED}  ✗${NC} $*"; }

echo ""
echo "=== Claude Code Plugin Install ==="
echo ""

if ! command -v claude &>/dev/null; then
    err "'claude' CLI not found in PATH."
    echo "    Install Claude Code first, then re-run this script."
    exit 1
fi

if ! command -v python3 &>/dev/null; then
    err "'python3' not found in PATH."
    echo "    Install Python 3, add it to PATH, then re-run this script."
    exit 1
fi

# ── Marketplaces ──────────────────────────────────────────────────────────────
# claude-plugins-official is built-in; the others need to be added.
echo "▸ Adding custom marketplaces"

declare -A MARKETPLACES=(
    ["claude-code-plugins"]="anthropics/claude-code"
    ["thedotmack"]="thedotmack/claude-mem"
    ["obsidian-skills"]="kepano/obsidian-skills"
)

for name in "${!MARKETPLACES[@]}"; do
    repo="${MARKETPLACES[$name]}"
    # Use grep with word boundary to avoid substring matches
    if claude plugin marketplace list 2>/dev/null | grep -qw "$name"; then
        ok "$name (already added)"
    else
        info "Adding marketplace: $name ($repo)"
        if claude plugin marketplace add "$repo" 2>/dev/null; then
            ok "Added $name"
        else
            warn "Failed to add $name — may already exist or network issue"
        fi
    fi
done

# ── Plugins ───────────────────────────────────────────────────────────────────
echo ""
echo "▸ Installing plugins"

if [[ ! -f "$PLUGINS_JSON" ]]; then
    warn "No installed_plugins.json found at $PLUGINS_JSON"
    warn "Run setup.sh first, or manually install plugins."
    exit 1
fi

# Parse plugin keys from installed_plugins.json using python3
# Keys are like "superpowers@claude-plugins-official"
PLUGIN_KEYS=$(python3 -c "
import json, sys
try:
    with open('$PLUGINS_JSON') as f:
        data = json.load(f)
    for key in data.get('plugins', {}):
        print(key)
except json.JSONDecodeError as e:
    print(f'ERROR: Invalid JSON in $PLUGINS_JSON: {e}', file=sys.stderr)
    sys.exit(1)
except FileNotFoundError:
    print(f'ERROR: File not found: $PLUGINS_JSON', file=sys.stderr)
    sys.exit(1)
") || { err "Failed to parse plugin list"; exit 1; }

while IFS= read -r plugin_key; do
    [[ -z "$plugin_key" ]] && continue
    info "Installing $plugin_key"
    if claude plugin install "$plugin_key" 2>/dev/null; then
        ok "Installed $plugin_key"
    else
        warn "Could not install $plugin_key (may already be installed)"
    fi
done <<< "$PLUGIN_KEYS"

# ── Apply enabled/disabled state ──────────────────────────────────────────────
echo ""
echo "▸ Applying plugin state"

# Plugins that should be DISABLED after install
DISABLED_PLUGINS=(
    "ralph-loop@claude-plugins-official"
)

for plugin in "${DISABLED_PLUGINS[@]}"; do
    info "Disabling $plugin"
    if claude plugin disable "$plugin" 2>/dev/null; then
        ok "Disabled $plugin"
    else
        warn "Could not disable $plugin (may already be disabled)"
    fi
done

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "=== Plugin install complete ==="
echo ""
echo "Restart Claude Code for all plugins to take effect."
echo ""
