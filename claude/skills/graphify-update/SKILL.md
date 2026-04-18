---
name: graphify-update
description: Use when user says /graphify-update or asks to update the graphify knowledge graph, sync graph outputs to Obsidian, or refresh codebase documentation
---

# graphify-update

Updates the graphify knowledge graph for the current repository and syncs all outputs to the Obsidian vault. The repo is whatever directory Claude Code is running in; the Obsidian subdirectory is derived from the repo name automatically.

## Configuration

| Variable | Value |
|----------|-------|
| Repo | Current working directory (`$PWD`) |
| Obsidian base | `/Users/herschel.menezes/Library/CloudStorage/OneDrive-Forcepoint,LLC/Obsidian/Work/Graphify` |
| Obsidian subdir | `$(basename $PWD)` — e.g. `epx-network-proxy` |
| Python | `/Users/herschel.menezes/.local/pipx/venvs/graphifyy/bin/python` |

## Steps

### Step 1 — Incremental graph update

```bash
PYTHON=/Users/herschel.menezes/.local/pipx/venvs/graphifyy/bin/python
"$PYTHON" -m graphify . --update
```

Graphify reads/writes cache relative to the current directory, so run from the repo root.

### Step 2 — Force-generate HTML visualization

The graph may exceed graphify's 5,000-node rendering limit. Always patch the limit before generating:

```bash
PYTHON=/Users/herschel.menezes/.local/pipx/venvs/graphifyy/bin/python
"$PYTHON" - <<'EOF'
import json, networkx as nx
import graphify.export as exp

exp.MAX_NODES_FOR_VIZ = 999999

with open('graphify-out/graph.json') as f:
    data = json.load(f)

G = nx.node_link_graph(data['graph'])
communities = data.get('communities', {})
exp.to_html(G, communities, 'graphify-out/graph.html', community_labels=None)
print(f"HTML generated: {len(G.nodes)} nodes, {len(G.edges)} edges")
EOF
```

### Step 3 — Sync to Obsidian vault

```bash
OBSIDIAN_BASE="/Users/herschel.menezes/Library/CloudStorage/OneDrive-Forcepoint,LLC/Obsidian/Work/Graphify"
OBSIDIAN="$OBSIDIAN_BASE/$(basename "$PWD")"

mkdir -p "$OBSIDIAN"

# Sync graphify-out (preserves cache for future --update runs), skip temp chunks
rsync -a --exclude='.graphify_chunk_*' graphify-out/ "$OBSIDIAN/graphify-out/"

# Copy key outputs to vault root for easy Obsidian access
cp graphify-out/GRAPH_REPORT.md "$OBSIDIAN/"
cp graphify-out/graph.json      "$OBSIDIAN/"
cp graphify-out/graph.html      "$OBSIDIAN/"

# Sync Obsidian node notes if generated
if [ -d graphify-out/obsidian ]; then
  rsync -a --delete graphify-out/obsidian/ "$OBSIDIAN/nodes/"
fi

echo "Sync complete → $OBSIDIAN"
```

## Summary output

After all steps complete, report:
- Repo name and node/edge count
- HTML file size
- Obsidian path where outputs were written
