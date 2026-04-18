---
name: transfer-plan-to-obsidian
description: Save the current session's latest Claude task plan to Obsidian under the current git branch name as the ticket ID. Auto-versions if a plan already exists. Use when user says "save my plan", "push plan to Obsidian", "transfer plan to notes", or "save this to my vault".
allowed-tools: ["Bash", "Read"]
arguments:
  - name: vault_path
    description: Override the hardcoded vault path for this run only.
    required: false
argument-hint: "[vault_path]"
---

# Transfer Plan to Obsidian

---

## Configuration (Edit Once)

```bash
OBSIDIAN_VAULT='/Users/herschel.menezes/Library/CloudStorage/OneDrive-Forcepoint,LLC/Obsidian/Work'
```

> Replace `/path/to/your/obsidian/vault` with your actual vault path before
> first use. This is the only line you need to edit.
> If `$vault_path` is passed at runtime, it overrides this value for that run only.

---

## Behavioural Rules

- **Ask first**: If no plan is clearly identifiable in the current session context,
  ask the user to point to it rather than guessing.
- **Never overwrite silently**: If `plan.md` already exists, always create a
  versioned file (`plan_v2.md`, `plan_v3.md`, etc.) automatically. Never
  delete or modify existing plan files.
- **CLAUDE.md updates**: This skill does not update CLAUDE.md.

---

## Step 1: Resolve Vault Path

```bash
VAULT="${vault_path:-'/Users/herschel.menezes/Library/CloudStorage/OneDrive-Forcepoint,LLC/Obsidian/Work'}"

if [ ! -d "$VAULT" ]; then
  echo "❌ Vault not found at: $VAULT"
  echo "Edit OBSIDIAN_VAULT in the skill or pass vault_path= as an argument."
  exit 1
fi
```

---

## Step 2: Get Ticket ID from Git Branch

```bash
TICKET_ID=$(git branch --show-current 2>/dev/null)

if [ -z "$TICKET_ID" ]; then
  echo "❌ Could not determine current git branch."
  echo "Are you inside a git repository?"
  exit 1
fi

echo "📌 Ticket ID (branch): $TICKET_ID"
```

Full branch name is used as-is as the ticket ID and folder name.
Example: branch `EPX-4217` → folder `Tickets/EPX-4217/`

---

## Step 3: Extract the Plan from Current Session

Look back through the current conversation and identify the **most recent task
plan Claude produced**. This is typically:

- A numbered or bulleted TODO list Claude wrote
- A step-by-step implementation plan
- A "here's what I'll do" breakdown before starting work
- A structured plan with phases or milestones

Use the **most recent one** if multiple exist in the session.
If no plan can be identified, ask the user to point to it before proceeding.

---

## Step 4: Resolve Versioned Filename

```bash
TARGET_DIR="$VAULT/Tickets/$TICKET_ID/ClaudePlan"
mkdir -p "$TARGET_DIR"

# Start at plan.md, increment version until a free filename is found
FILENAME="plan.md"
VERSION=2

while [ -f "$TARGET_DIR/$FILENAME" ]; do
  FILENAME="plan_v${VERSION}.md"
  VERSION=$((VERSION + 1))
done

TARGET_FILE="$TARGET_DIR/$FILENAME"
echo "📄 Writing to: $FILENAME (version $((VERSION - 1)) of this ticket's plans)"
```

This means:
- First save → `plan.md`
- Second save → `plan_v2.md`
- Third save → `plan_v3.md`
- And so on — all previous plans are preserved

---

## Step 5: Build the Markdown File

```markdown
# Plan — {{TICKET_ID}}

**Branch**: `{{TICKET_ID}}`
**File**: `{{FILENAME}}`
**Saved**: {{ISO_DATETIME}}
**Repo**: {{git remote get-url origin}}

---

## Context

{{1–3 sentence summary of what this ticket/task is about, inferred from the plan}}

---

## Plan

{{The extracted plan from the session — reproduce faithfully.
Preserve numbered steps, phases, bullet points, and code blocks.
Do not summarise or paraphrase.}}

---

## Notes

{{Relevant caveats, open questions, or decisions made during the session.
Leave blank if none.}}
```

---

## Step 6: Write and Confirm

```bash
cat > "$TARGET_FILE" << 'EOF'
{{rendered plan.md content}}
EOF

echo "✅ Plan saved to Obsidian"
echo ""
echo "📁 Location : $TARGET_FILE"
echo "📌 Ticket   : $TICKET_ID"
echo "📄 File     : $FILENAME"
echo "📅 Saved    : $(TZ='Asia/Kolkata' date +"%Y-%m-%dT%H:%M:%S%z")"
```

Provide an Obsidian deep link for direct access:
```
obsidian://open?vault={{vault_name}}&file=Tickets/{{TICKET_ID}}/ClaudePlan/{{FILENAME}}
```

Derive `vault_name` from the last path component of `$VAULT`.

---

## Sequential Thinking Integration

After installation, invoke by asking Claude to "think through this problem step by step"
or "use sequential thinking to analyze this architecture."
