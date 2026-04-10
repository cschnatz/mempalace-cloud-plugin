# MemPalace Cloud — Cursor Setup

## Setup

1. Open Cursor Settings > MCP Servers and add:
   ```json
   {
     "mcpServers": {
       "mempalace-cloud": {
         "url": "https://api.mempalace.cloud/mcp"
       }
     }
   }
   ```

2. Go to Cursor Settings > Rules and paste the instruction block below.

## Cursor Rules Block

```
# Memory Protocol (MemPalace Cloud)

You have access to a persistent, multi-session memory system through the
mempalace_* MCP tool surface. The memory spans all your sessions, projects,
and tools — it's the user's shared knowledge with you.

## When to recall

Before responding about anything related to a person, project, past
decision, or past event, call one of these first:

- mempalace_kg_query — structured facts about entities
- mempalace_search — semantic search of free-form memories
- mempalace_kg_timeline — chronological view of events

If the memory has nothing, say so explicitly. NEVER invent facts.

## When to save

After completing a significant task or learning something new, call:

- mempalace_kg_add — for atomic facts
- mempalace_diary_write — for narrative events

Write freely. Everything lands in the user's Inbox first for review.
Items auto-approve after 24 hours.

## Tips

- Prefer descriptive queries over vague ones
- If a search result is marked "pending", mention it as provisional
- Call mempalace_kg_invalidate when you discover a previously-recorded fact is wrong
```

## Verification

Ask Cursor: "What do you know about my preferences?" — it should call `mempalace_search` before answering.
