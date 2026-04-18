#!/usr/bin/env bash
# backup-mem.sh — Back up claude-mem project memory to Obsidian vault,
#                 and snapshot project CLAUDE.md files into dotfiles.
#
# Run periodically (or after significant sessions) to keep Obsidian and
# dotfiles in sync with your latest Claude memory and project instructions.
set -euo pipefail

DOTFILES_CLAUDE="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_HOME="$HOME/.claude"
OBSIDIAN_MEM="$HOME/Library/CloudStorage/OneDrive-Forcepoint,LLC/Obsidian/Work/claude-mem"
PROJECT_CLAUDE_DEST="$DOTFILES_CLAUDE/project-claude-md"
MANIFEST="$PROJECT_CLAUDE_DEST/manifest.txt"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}  →${NC} $*"; }
ok()      { echo -e "${GREEN}  ✓${NC} $*"; }
skipped() { echo -e "${YELLOW}  ⏭${NC} $*"; }

echo ""
echo "=== Claude Memory & Project Config Backup ==="
echo ""

# ── claude-mem project memory → Obsidian vault ───────────────────────────────
echo "▸ Backing up claude-mem memory to Obsidian"

if [[ ! -d "$OBSIDIAN_MEM" ]]; then
    info "Creating Obsidian claude-mem directory: $OBSIDIAN_MEM"
    mkdir -p "$OBSIDIAN_MEM"
fi

MEMORY_BACKED_UP=0

for proj_dir in "$CLAUDE_HOME/projects"/*/; do
    [[ -d "$proj_dir/memory" ]] || continue
    # Count actual files (skip empty dirs)
    file_count=$(find "$proj_dir/memory" -type f | wc -l | tr -d ' ')
    [[ "$file_count" -eq 0 ]] && continue

    # Decode project dir name to human-readable label
    # Dir names look like: -Users-herschel-menezes-Projects-EPM-epm-f1e
    # Strategy: strip common prefix, then use the remainder as the label
    proj_name="$(basename "$proj_dir")"

    # Strip the -Users-<username>- prefix
    label="${proj_name#-Users-*-}"
    # Replace remaining leading hyphens and clean up
    label="${label#-}"
    # Convert path separators (hyphens used as separators) to a readable form
    # Take the last meaningful segment (project name) for short Obsidian subdir
    # e.g. "-Users-herschel-menezes-Projects-EPM-epm-f1e" → "EPM-epm-f1e"
    # We split by "-Projects-" to get just the project path part
    if [[ "$proj_name" == *"-Projects-"* ]]; then
        label="${proj_name##*-Projects-}"
    elif [[ "$proj_name" == *"-Users-"* ]]; then
        label="${proj_name##*-Users-}"
        label="${label#*-}"  # strip username
        [[ -z "$label" ]] && label="home"
    else
        label="$proj_name"
    fi

    obsidian_subdir="$OBSIDIAN_MEM/$label"
    mkdir -p "$obsidian_subdir"

    info "Syncing memory: $label ($file_count files)"
    rsync -a --delete "$proj_dir/memory/" "$obsidian_subdir/"
    ok "Synced → $obsidian_subdir"
    (( MEMORY_BACKED_UP++ )) || true
done

if [[ "$MEMORY_BACKED_UP" -eq 0 ]]; then
    skipped "No project memory directories found"
fi

# ── claude-mem observer sessions → Obsidian vault ────────────────────────────
echo ""
echo "▸ Backing up claude-mem observer sessions (session history DB)"

OBSERVER_SRC="$CLAUDE_HOME/projects/-Users-herschel-menezes--claude-mem-observer-sessions"
OBSERVER_DEST="$OBSIDIAN_MEM/_observer-sessions"

if [[ -d "$OBSERVER_SRC" ]]; then
    file_count=$(find "$OBSERVER_SRC" -name "*.jsonl" -type f | wc -l | tr -d ' ')
    size=$(du -sh "$OBSERVER_SRC" | cut -f1)
    info "Syncing observer sessions ($file_count files, $size)"
    mkdir -p "$OBSERVER_DEST"
    rsync -a --delete "$OBSERVER_SRC/" "$OBSERVER_DEST/"
    ok "Synced observer sessions → $OBSERVER_DEST"
else
    skipped "No claude-mem observer sessions found"
fi

# ── Auto-discover project CLAUDE.md files ────────────────────────────────────
echo ""
echo "▸ Backing up project CLAUDE.md files"

mkdir -p "$PROJECT_CLAUDE_DEST"
: > "$MANIFEST"  # Clear manifest

CLAUDE_MD_COUNT=0

while IFS= read -r -d $'\0' claude_path; do
    # Convert absolute path to a safe filename using __ as separator
    # Strip $HOME/ prefix, then replace / with __
    rel="${claude_path#$HOME/}"
    safe_name="${rel//\//__}"

    cp "$claude_path" "$PROJECT_CLAUDE_DEST/$safe_name"
    echo "$safe_name|$claude_path" >> "$MANIFEST"
    info "Saved: $rel"
    (( CLAUDE_MD_COUNT++ )) || true
done < <(find "$HOME/Projects" \
    -maxdepth 4 \
    -name "CLAUDE.md" \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/build/*" \
    -not -path "*/dist/*" \
    -print0 2>/dev/null)

if [[ "$CLAUDE_MD_COUNT" -gt 0 ]]; then
    ok "Backed up $CLAUDE_MD_COUNT project CLAUDE.md file(s)"
else
    skipped "No project CLAUDE.md files found under ~/Projects"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "=== Backup complete ==="
echo ""
[[ "$MEMORY_BACKED_UP" -gt 0 ]] && echo "  Memory synced to: $OBSIDIAN_MEM"
[[ "$CLAUDE_MD_COUNT"  -gt 0 ]] && echo "  CLAUDE.md files:  $PROJECT_CLAUDE_DEST"
echo ""
echo "To restore project CLAUDE.md files on a new machine, run:"
echo "  bash $(dirname "$0")/restore-projects.sh"
echo ""
