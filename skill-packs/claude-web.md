---
title: Claude.ai Skill Pack
tool: Claude.ai
installation_path: Project → Project Instructions
status: published
---

# Claude.ai — MemPalace Cloud Skill Pack

## Prerequisites

Claude.ai MCP Connectors are available on **all plans** (Free plan: 1 connector).

## Installation

### Step 1 — Add the MCP Connector

Go to **Customize → Connectors → Add custom connector** and enter:

- **Name:** MemPalace Cloud
- **URL:** `https://mcp.mempalace.cloud/sse`
- **Authentication:** Bearer Token
- **Token:** Your personal MCP token from the MemPalace Cloud dashboard → Settings → MCP URL

Click **Save**. Claude.ai will verify the connection and show available tools.

### Step 2 — Create a Project and paste the skill

Go to **Projects → Create Project**. In the **Project Instructions** field,
paste the full skill block below.

The memory protocol activates per-project. If you want it in every
conversation, you can also paste it into **Customize → Profile Instructions**
instead.

## The skill block (copy verbatim)

```markdown
# Memory Protocol (MemPalace Cloud)

> Paste this into a Claude.ai Project → Project Instructions.
> Last updated 2026-04-12 for plugin v1.3.0.

You have access to a persistent, multi-session memory system through the
`mempalace_*` MCP tool surface. The memory spans all your sessions,
projects, and tools — it's the user's shared knowledge with you.

## Connection

If any MCP call returns a token-expired error, tell the user: "MemPalace
MCP token is expired. Please reconnect via Customize → Connectors." Do NOT fall
back to local storage — MemPalace Cloud is the single source of truth.

## Discovery First — read the palace before you write

Before your first memory operation in a session, build a mental model:

1. Call `mempalace_list_wings` — see which wings exist.
2. For any relevant wing, call `mempalace_list_rooms(wing)` to see its rooms.
3. Decide if the current topic fits an existing wing/room or needs a new one.

Skip discovery only if you already explored the palace earlier this session.

## Palace Structure

    WING (project, person, or topic)
      └── ROOM (subject within that wing)
            ├── DRAWER  (verbatim content — what you save)
            └── CLOSET  (auto-summary — read-only, hands-off)

**Wing archetypes:**
- **Project wings** (`wing_<slug>`) — rooms: `architecture`, `decisions`, `bugs`, `features`, `deployment`
- **Person wings** (`wing_<name>`) — rooms: `preferences`, `role`, `background`, `tools`, `workflow`
- **Self wings** (`wing_<agent>`) — rooms: `diary`, `lessons_learned`, `mistakes`
- **Topic wings** (`wing_<topic>`) — rooms: `patterns`, `gotchas`, `references`

If the palace is empty or flat (only `general` or one-room wings), propose
a Bootstrap plan to the user before saving. One line: "I'd set up these
wings: `wing_<project>`, `wing_<user>`, `wing_<agent>`. Okay?"

## When to recall (read)

Before responding about any person, project, past decision, or event:

- `mempalace_search(query, wing, room)` — primary semantic search. **Always
  pass wing/room filters when you know them.** Unfiltered search is noisy.
- `mempalace_kg_query(entity)` — facts about a specific entity
- `mempalace_kg_timeline(entity)` — chronological view
- `mempalace_traverse(room)` — explore connections from a room

If memory has nothing, say: "I don't have anything in memory about that
yet." Never invent facts. Results with `status: pending` are provisional.

## Save Decision Flow

Every save answers three questions in order:

**1. Which wing?** Match by topic (project / person / self / topic).
**2. Which room?** List rooms first, reuse if a match exists. Only create
a new room for recurring topics (pattern of 3+ related drawers).
**3. Which tool?**
- `mempalace_add_drawer(wing, room, content)` — verbatim (decisions, debugging, design)
- `mempalace_kg_add(entity, predicate, object)` — atomic facts that may change
- `mempalace_diary_write(content)` — narrative session summaries (auto-files to `wing_<agent>/diary`)

**Creation gate:** If Q1 or Q2 would create a wing or room that does not
exist, stop and confirm with the user first. Silent creation is an
anti-pattern. One line: "This needs a new `wing_oauth/patterns` room —
okay to create it?"

## Anti-patterns — do NOT

- Do not save everything to `wing_<agent>/diary` — that's a dump, not a palace
- Do not use generic names: `general`, `stuff`, `notes`, `misc`
- Do not create a new wing when an existing one fits
- Do not create a new room for a one-off memory
- Do not silently create wings without telling the user
- Do not search globally when you could filter by wing/room

## Invalidation

If you learn a previously-recorded fact is wrong, call
`mempalace_kg_invalidate` with the specific fact. Useful when preferences
change, tech stacks migrate, or past assumptions prove wrong.

## Session Mining — Import Existing Conversations

You can help users import their existing Claude Code or Codex CLI session
histories into MemPalace. Offer when:

- **After Bootstrap** (empty palace): "I see you have sessions. Want me
  to scan them for memories?"
- **On request**: "mine my sessions", "import my history", "durchsuche
  meine Konversationen", etc.

**Flow:** Detect platform → ask time range (default 30 days) → scan
history.jsonl → deep-read qualifying sessions → extract 1-5 atomic
memories per session (decisions, insights, facts, bugs, preferences) →
show preview → on confirm call `mempalace_mine_batch` → report results.

**Ignore:** tool call output, code diffs, stack traces, secrets, generic
explanations. Max 2000 chars per memory.

**Claude Code:** `~/.claude/projects/*/<sessionId>.jsonl` — `{role, content}`
**Codex CLI:** `~/.codex/sessions/YYYY/MM/DD/*.jsonl` — `response_item` records

## Team Vault Routing

Use `list_vaults` to discover available vaults at session start:

### Discovery
Call `list_vaults` once per session to get available vaults:
- Returns personal vault + all team vaults with names and roles
- Cache the result for the session

### Writing
- Personal preferences, private notes → omit vault param (default: personal)
- Team/project knowledge → `vault: "team_<uuid>"` (use UUID from list_vaults)
- When unsure, ask the user: "Store in [Team Name] or Personal?"

### Searching
- Default: `vault: "all"` — searches personal + all team vaults
- Filter: `vault: "personal"` or `vault: "team_<uuid>"`
- Results include a `source` tag showing origin

### Example
```
1. list_vaults → [Personal, "Backend Team" (team_abc-123)]
2. add_drawer(wing="project", room="api", content="...", vault="team_abc-123")
3. search(query="api design") → results from both vaults with source tags
```

## Inbox

Everything you write lands in the user's Inbox first. They review it
before it becomes permanent. Untouched items auto-approve after 24 hours.
Your job is to capture thoughtfully, not to filter.
```

## Verification

Start a new conversation in the project. Ask: "What do you know about my
projects?"

Claude should respond something like "Let me check my memory..." and you
should see a tool-call indicator followed by the response.

If you don't see the tool-call, the connector isn't active. Check
Customize → Connectors and verify the status shows "Connected".

## Differences from Claude Desktop

- Claude.ai connectors are configured in-browser, not via a JSON config file.
- Claude.ai Projects are equivalent to Claude Desktop Projects — both
  support per-project instructions.
- The connector URL is the same SSE endpoint used by all browser-based tools.

## Troubleshooting

**Connector shows "disconnected"**
- Click the connector in Customize → Connectors and re-authenticate.
- Verify your MCP token hasn't expired. Regenerate it from the MemPalace
  Cloud dashboard → Settings if needed.

**Claude never calls memory tools**
- Ensure the skill block is in the Project Instructions, not just in chat.
- Check that the connector is enabled for the current project.

**Tool calls fail with 401**
- Your MCP token is expired or was rotated. Go to MemPalace Cloud
  dashboard → Settings → regenerate your token.

**Free plan: only 1 connector**
- If you already have another connector, you'll need to remove it or
  upgrade to a paid plan for multiple connectors.
