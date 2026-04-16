---
title: ChatGPT Skill Pack
tool: ChatGPT
installation_path: Custom Instructions
status: published
---

# ChatGPT — MemPalace Cloud Skill Pack

## Prerequisites

ChatGPT MCP Connectors require **Teams, Pro, or Enterprise** plan.
Developer Mode must be enabled (see Step 1).

## Installation

### Step 1 — Enable Developer Mode

Open **Settings → Apps → Developer Mode** and toggle it on.
This is available on Web and Desktop only (not mobile).

### Step 2 — Create a Connector

Go to **Settings → Apps → MCP Servers** and add a new connector:

- **Name:** MemPalace Cloud
- **URL:** `https://mcp.mempalace.cloud/sse`
- **Authentication:** Bearer Token
- **Token:** Your personal MCP token from the MemPalace Cloud dashboard → Settings → MCP URL

Click **Save**. ChatGPT will verify the connection and show available tools.

### Step 3 — Add the compact skill to Custom Instructions

Go to **Settings → Personalization → Custom Instructions** and paste the
skill block below into the "What would you like ChatGPT to know about you?"
or "How would you like ChatGPT to respond?" field.

Because Custom Instructions has a character limit, this is a compact version
of the full memory protocol.

## The skill block (copy verbatim)

```markdown
# Memory Protocol (MemPalace Cloud)

> Paste into ChatGPT Custom Instructions. Updated 2026-04-14, v1.3.0.

You have persistent memory via `mempalace_*` MCP tools. Memory spans all sessions and tools.

## Discovery First
Before your first memory operation, call `mempalace_list_wings` then `mempalace_list_rooms(wing)` for relevant wings. Know the palace before you write.

## When to recall
Before answering about any person, project, or past event, search first:
- `mempalace_search(query, wing, room)` — always pass wing/room filters
- `mempalace_kg_query(entity)` — facts about a specific entity
If nothing found, say so. Never invent facts.

## Save Decision Flow
Every save answers three questions:
1. **Which wing?** (project / person / self / topic)
2. **Which room?** List existing rooms first. Only create new for recurring topics.
3. **Which tool?** `mempalace_add_drawer` for content, `mempalace_kg_add` for facts, `mempalace_diary_write` for session summaries.

If creating a new wing or room, confirm with the user first.

## Team Vault Routing
Call `list_vaults` once per session. Use `vault: "team_<uuid>"` for team knowledge, omit for personal. Default search is `vault: "all"`. Results show source tag.

## Do NOT
- Dump everything into diary
- Use generic names (general, stuff, notes)
- Create wings/rooms silently
- Search globally when you could filter by wing/room

Everything you save lands in the user's Inbox for review first.
```

## Verification

Start a new conversation. Ask: "What do you know about my projects?"

ChatGPT should call a `mempalace_*` tool (visible in the tool-call indicator)
before responding. If it doesn't, verify the connector is active in
Settings → Apps → MCP Servers.

## Troubleshooting

**Connector shows "disconnected"**
- Verify your MCP token hasn't expired. Regenerate it from the MemPalace
  Cloud dashboard → Settings if needed.

**ChatGPT never calls memory tools**
- Ensure the skill block is in Custom Instructions, not just in chat history.
- Developer Mode must be enabled for MCP tools to appear.

**Tool calls fail with 401**
- Your MCP token is expired or was rotated. Go to MemPalace Cloud
  dashboard → Settings → regenerate your token.

**Character limit exceeded**
- The compact skill block above is designed to fit within ChatGPT's Custom
  Instructions limit. If you've added other instructions, you may need to
  trim them.
