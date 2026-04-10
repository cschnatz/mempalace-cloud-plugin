#!/bin/bash
# MemPalace Cloud Stop Hook — pure shell, no Python dependency
# Counts human messages and triggers save every 15 exchanges
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('session_id','unknown'))" 2>/dev/null || echo "unknown")
STOP_ACTIVE=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('stop_hook_active',False))" 2>/dev/null || echo "False")
TRANSCRIPT=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('transcript_path',''))" 2>/dev/null || echo "")

# If already in a save cycle, pass through (infinite-loop prevention)
if [ "$STOP_ACTIVE" = "True" ] || [ "$STOP_ACTIVE" = "true" ]; then
    echo '{}'
    exit 0
fi

# Count human messages (exclude command-messages)
COUNT=0
if [ -f "$TRANSCRIPT" ]; then
    COUNT=$(python3 -c "
import json
count = 0
with open('$TRANSCRIPT', errors='replace') as f:
    for line in f:
        try:
            e = json.loads(line)
            m = e.get('message', {})
            if isinstance(m, dict) and m.get('role') == 'user':
                c = m.get('content', '')
                text = c if isinstance(c, str) else ' '.join(b.get('text','') for b in c if isinstance(b, dict))
                if '<command-message>' not in text:
                    count += 1
        except: pass
print(count)
" 2>/dev/null || echo "0")
fi

# Track last save point
STATE_DIR="$HOME/.mempalace/hook_state"
mkdir -p "$STATE_DIR"
SAVE_FILE="$STATE_DIR/${SESSION_ID}_last_save"

LAST_SAVE=0
if [ -f "$SAVE_FILE" ]; then
    LAST_SAVE=$(cat "$SAVE_FILE" 2>/dev/null || echo "0")
fi

SINCE_LAST=$((COUNT - LAST_SAVE))

if [ "$SINCE_LAST" -ge 15 ] && [ "$COUNT" -gt 0 ]; then
    echo "$COUNT" > "$SAVE_FILE"
    echo '{"decision":"block","reason":"AUTO-SAVE checkpoint. Save key topics, decisions, and learnings from this session to MemPalace Cloud using mempalace_diary_write and mempalace_kg_add. If MCP token is expired, tell the user to re-authenticate with /mcp. Continue conversation after saving."}'
else
    echo '{}'
fi
