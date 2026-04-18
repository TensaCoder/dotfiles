#!/usr/bin/env bash
# setup.sh — Symlink Claude Code config files to this dotfiles directory.
#
# First run: migrates existing ~/.claude/ files into dotfiles/claude/config/
#            and dotfiles/claude/skills/, then creates symlinks.
# Subsequent runs: no-ops for already-symlinked items (idempotent).
#
# Does NOT install plugins — run install-plugins.sh for that.
set -euo pipefail

DOTFILES_CLAUDE="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_HOME="$HOME/.claude"
CONFIG_DEST="$DOTFILES_CLAUDE/config"
SKILLS_DEST="$DOTFILES_CLAUDE/skills"
COMMANDS_DEST="$DOTFILES_CLAUDE/commands"
PLUGINS_DEST="$DOTFILES_CLAUDE/plugins"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}  →${NC} $*"; }
ok()      { echo -e "${GREEN}  ✓${NC} $*"; }
skipped() { echo -e "${YELLOW}  ⏭${NC} $*"; }

echo ""
echo "=== Claude Code Symlink Setup ==="
echo "Dotfiles: $DOTFILES_CLAUDE"
echo "Claude:   $CLAUDE_HOME"
echo ""

mkdir -p "$CLAUDE_HOME" "$CONFIG_DEST" "$SKILLS_DEST" "$COMMANDS_DEST" "$PLUGINS_DEST"

# ── Config files ──────────────────────────────────────────────────────────────
echo "▸ Config files"

CONFIG_FILES=(
    CLAUDE.md
    settings.json
    settings.local.json
    keybindings.json
    policy-limits.json
    statusline-command.sh
)

for f in "${CONFIG_FILES[@]}"; do
    src="$CLAUDE_HOME/$f"
    dest="$CONFIG_DEST/$f"

    if [[ -L "$src" ]]; then
        skipped "$f (already symlinked)"
        continue
    fi

    if [[ -f "$src" ]] && [[ ! -f "$dest" ]]; then
        mv "$src" "$dest"
        info "Migrated $f → dotfiles"
    elif [[ -f "$src" ]] && [[ -f "$dest" ]]; then
        info "$f exists in both locations — keeping dotfiles version, removing ~/.claude copy"
        rm "$src"
    fi

    if [[ -f "$dest" ]]; then
        ln -s "$dest" "$src"
        ok "Symlinked $f"
    else
        skipped "$f (not found in either location)"
    fi
done

# Make statusline executable if it exists
if [[ -f "$CONFIG_DEST/statusline-command.sh" ]]; then
    chmod +x "$CONFIG_DEST/statusline-command.sh"
fi

# ── Skills directory ──────────────────────────────────────────────────────────
echo ""
echo "▸ Skills directory"

SKILLS_SRC="$CLAUDE_HOME/skills"

if [[ -L "$SKILLS_SRC" ]]; then
    skipped "skills/ (already symlinked)"
elif [[ -d "$SKILLS_SRC" ]]; then
    info "Migrating skills/ → dotfiles"
    # Copy contents into dotfiles/skills (merge, not overwrite)
    if cp -Rn "$SKILLS_SRC/." "$SKILLS_DEST/" 2>/dev/null; then
        rm -rf "$SKILLS_SRC"
        ln -s "$SKILLS_DEST" "$SKILLS_SRC"
        ok "Migrated and symlinked skills/"
    else
        echo ""
        echo "ERROR: Failed to copy skills to dotfiles. Aborting to preserve source."
        echo "  Source: $SKILLS_SRC"
        echo "  Dest:   $SKILLS_DEST"
        echo "  Check permissions and disk space, then re-run."
        exit 1
    fi
else
    mkdir -p "$SKILLS_DEST"
    ln -s "$SKILLS_DEST" "$SKILLS_SRC"
    ok "Symlinked skills/ (was empty)"
fi

# ── Commands directory ─────────────────────────────────────────────────────────
echo ""
echo "▸ Commands directory"

COMMANDS_SRC="$CLAUDE_HOME/commands"

if [[ -L "$COMMANDS_SRC" ]]; then
    skipped "commands/ (already symlinked)"
elif [[ -d "$COMMANDS_SRC" ]]; then
    info "Migrating commands/ → dotfiles"
    if cp -Rn "$COMMANDS_SRC/." "$COMMANDS_DEST/" 2>/dev/null; then
        rm -rf "$COMMANDS_SRC"
        ln -s "$COMMANDS_DEST" "$COMMANDS_SRC"
        ok "Migrated and symlinked commands/"
    else
        echo ""
        echo "ERROR: Failed to copy commands to dotfiles. Aborting to preserve source."
        echo "  Source: $COMMANDS_SRC"
        echo "  Dest:   $COMMANDS_DEST"
        echo "  Check permissions and disk space, then re-run."
        exit 1
    fi
else
    mkdir -p "$COMMANDS_DEST"
    ln -s "$COMMANDS_DEST" "$COMMANDS_SRC"
    ok "Symlinked commands/ (was empty)"
fi

# ── Plugin metadata (copy, not symlink — these are machine-specific) ──────────
echo ""
echo "▸ Plugin metadata snapshot"

PLUGIN_META_FILES=(installed_plugins.json known_marketplaces.json blocklist.json)
for f in "${PLUGIN_META_FILES[@]}"; do
    if [[ -f "$CLAUDE_HOME/plugins/$f" ]]; then
        cp "$CLAUDE_HOME/plugins/$f" "$PLUGINS_DEST/$f"
        ok "Saved plugins/$f"
    else
        skipped "plugins/$f (not found)"
    fi
done

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "=== Setup complete ==="
echo ""
echo "Verify with:"
echo "  ls -la ~/.claude/CLAUDE.md ~/.claude/settings.json ~/.claude/skills"
echo ""
echo "To install plugins on a new machine, run:"
echo "  bash $(dirname "$0")/install-plugins.sh"
echo ""
