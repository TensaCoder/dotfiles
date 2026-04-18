#!/usr/bin/env bash
# restore-projects.sh — Restore project CLAUDE.md files from the dotfiles backup.
#
# Only restores a file if its target project directory already exists on
# this machine (projects must be cloned first).
set -euo pipefail

DOTFILES_CLAUDE="$(cd "$(dirname "$0")" && pwd)"
PROJECT_CLAUDE_DEST="$DOTFILES_CLAUDE/project-claude-md"
MANIFEST="$PROJECT_CLAUDE_DEST/manifest.txt"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ok()      { echo -e "${GREEN}  ✓${NC} $*"; }
skipped() { echo -e "${YELLOW}  ⏭${NC} $*"; }

echo ""
echo "=== Restore Project CLAUDE.md Files ==="
echo ""

if [[ ! -f "$MANIFEST" ]]; then
    echo "No manifest found at $MANIFEST — run backup-mem.sh first."
    exit 0
fi

RESTORED=0
SKIPPED=0

while IFS='|' read -r safe_name original_path; do
    [[ -z "$safe_name" ]] && continue
    src="$PROJECT_CLAUDE_DEST/$safe_name"
    target_dir="$(dirname "$original_path")"

    if [[ ! -f "$src" ]]; then
        skipped "$original_path (backup file missing)"
        (( SKIPPED++ )) || true
        continue
    fi

    if [[ -d "$target_dir" ]]; then
        cp "$src" "$original_path"
        ok "Restored: $original_path"
        (( RESTORED++ )) || true
    else
        skipped "$original_path (project dir not found: $target_dir)"
        (( SKIPPED++ )) || true
    fi
done < "$MANIFEST"

echo ""
echo "Restored: $RESTORED  |  Skipped: $SKIPPED"
echo ""
