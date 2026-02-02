#!/bin/bash
# summarize-pending.sh — Sub-agent summarization task
#
# This script is meant to be run BY a sub-agent (via sessions_spawn).
# It reads pending-memories.json and outputs instructions for summarization.
#
# Usage: Called by sub-agent task

WORKSPACE="${WORKSPACE:-$HOME/.openclaw/workspace}"
PENDING_FILE="$WORKSPACE/memory/pending-memories.json"
INDEX_FILE="$WORKSPACE/memory/index.json"
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🧠 HIPPOCAMPUS SUMMARIZATION TASK"
echo "=================================="
echo ""

if [ ! -f "$PENDING_FILE" ]; then
    echo "No pending memories file found."
    exit 0
fi

PENDING_COUNT=$(python3 -c "import json; d=json.load(open('$PENDING_FILE')); print(len(d.get('pending',[])))" 2>/dev/null || echo "0")

if [ "$PENDING_COUNT" -eq 0 ]; then
    echo "No pending memories to process."
    exit 0
fi

echo "Found $PENDING_COUNT memories to summarize."
echo ""
echo "=== PENDING MEMORIES ==="
cat "$PENDING_FILE"
echo ""
echo "=== END PENDING ==="
echo ""
echo "INDEX FILE: $INDEX_FILE"
echo "PENDING FILE: $PENDING_FILE"
echo ""
echo "=== INSTRUCTIONS ==="
echo "For each pending memory:"
echo "1. Read the 'raw_text' field"
echo "2. Create a CONCISE summary (max 100 chars)"
echo "3. Format: Start with 'User' or 'Agent' as subject"
echo "4. Keep: facts, preferences, emotions, decisions, insights"
echo "5. Remove: filler, metadata, timestamps, routine confirmations"
echo ""
echo "Examples of GOOD summaries:"
echo "  - User prefers local-only solutions, avoids third-party storage"
echo "  - User decided to use sub-agent approach for summarization"
echo "  - Agent discovered encoding wasn't summarizing — just copying raw text"
echo "  - Agent fixed bug: changed sorting method to pick correct session file"
echo ""
echo "Examples of BAD summaries (too verbose/raw):"
echo "  - User said: what about the hippocampus_core - can you check..."
echo "  - Agent noted: Found the bug! \`\`\`python def extract_content..."
echo ""
echo "After summarizing, update index.json:"
echo "  - Add each memory to 'memories' array"
echo "  - Use the 'id', 'domain', 'category', 'score' from pending"
echo "  - Set 'content' to your summary"
echo "  - Set 'importance' to the 'score' value"
echo "  - Set 'lastAccessed' and 'created' to today"
echo "  - Set 'timesReinforced' to 1"
echo ""
echo "Then delete $PENDING_FILE"
echo "Then run: $SKILL_DIR/scripts/sync-core.sh"
