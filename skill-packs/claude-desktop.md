---
title: Claude Desktop Skill Pack
tool: Claude Desktop (Mac/Windows)
installation_path: Claude Desktop → Project → Instructions
status: draft for Sprint 7
---

# Claude Desktop — MemPalace Cloud Skill Pack

## Installation

Claude Desktop uses MCP servers configured at the OS level and supports per-Project instructions.

### Step 1 — Add the MCP server

On **macOS**: edit `~/Library/Application Support/Claude/claude_desktop_config.json`

On **Windows**: edit `%APPDATA%\Claude\claude_desktop_config.json`

Add this entry under `mcpServers`:

```json
{
  "mcpServers": {
    "mempalace-cloud": {
      "command": "npx",
      "args": [
        "@mempalace-cloud/mcp-client",
        "--url",
        "https://mcp.mempalace.cloud/u/YOUR_PERSONAL_TOKEN"
      ]
    }
  }
}
```

Replace `YOUR_PERSONAL_TOKEN` with the value from your MemPalace Cloud dashboard → Settings → MCP URL.

Restart Claude Desktop. In the chat compose bar, you should see a 🔌 icon
indicating an MCP server is connected.

### Step 2 — Add the skill to a Project

Claude Desktop supports "Projects" which have their own instructions. For the
memory protocol to activate, create a project and paste the skill block below
into **Project Instructions**.

If you prefer a global version that applies to every conversation, paste the
block into **Settings → Custom Instructions → How would you like Claude to
respond?** instead.

## The skill block (copy verbatim)

```markdown
MEMORY PROTOCOL — You have access to the MemPalace Cloud memory system via
MCP tools prefixed `mempalace_*`. Follow this protocol strictly:

BEFORE responding about any person, project, past decision, or past event,
pick the right lookup tool for the question type:

• Specific named entity (person, company, product name)? → Call
  `mempalace_kg_query(entity="<normalized_name>")` FIRST. The knowledge
  graph is authoritative for named facts and direct lookup is always
  reliable.
• Narrative / semantic question ("what do we know about retention")? →
  Call `mempalace_search(query="...")`.
• If `mempalace_search` returns only generic drawers that do not match
  your question → fall back to `mempalace_list_drawers(wing=..., room=...)`
  to enumerate rooms directly. Proper-noun queries are unreliable in
  semantic search (upstream bug); `kg_query` and `list_drawers` are not
  affected.

Do not guess. If all lookups turn up nothing, say so: "I don't have
anything in memory about that yet."

AFTER completing a significant task or learning something new: call
`mempalace_kg_add` (for atomic facts) or `mempalace_diary_write` (for
narrative events) or `mempalace_add_drawer` (for larger knowledge chunks).
Memory-worthy: bugs tracked down, design decisions with rationale, team
preferences, milestones, lessons learned.

Write freely. All captures land in the user's Inbox for review — they auto-
approve after 24 hours. Don't second-guess whether something is "worth"
saving; let the user filter.

When search results are marked `status: pending`, mention them as
unconfirmed: "Based on a note captured earlier (not yet reviewed): ..."

If you discover a fact is wrong, call `mempalace_kg_invalidate` with the
specific fact ID.

On every new conversation, you may optionally call `mempalace_status` to
refresh the protocol reminder and load the AAAK dialect specification.

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
```

## New Parameters (v1.4.0)

- `mempalace_add_drawer`: `wing` and `room` are now **required**. Always specify both.
- `mempalace_kg_add`: Use `valid_from` (YYYY-MM-DD) for temporal facts.
- `mempalace_kg_query`: Use `as_of` for point-in-time queries, `direction` for outgoing/incoming/both.
- `mempalace_kg_invalidate`: Use `ended` to set a specific end date.
- `mempalace_search`: Optional `context` param for background context (logged for future use).

After updating, reconnect MCP (`/mcp` or restart client) to load new tool schemas.

## Verification

Start a new conversation in the project. Ask: "What do you know about my
projects?"

Claude should respond something like "Let me check my memory..." and you
should see a tool-call indicator (⚙️ or similar) followed by the response.

If you don't see the tool-call, the MCP server isn't connected. Check the
Claude Desktop logs at `~/Library/Logs/Claude/` (macOS) for MCP connection
errors.

## Differences from Claude Code

- Claude Desktop's Project Instructions are more visible to the user than
  Claude Code's `CLAUDE.md` — the user can see and edit them in the UI.
- Claude Desktop does not automatically pick up a project-root `CLAUDE.md`;
  you must paste the skill into the Project Instructions field explicitly.
- Claude Desktop's MCP integration is per-installation, not per-project.
  The MCP URL you paste applies to all conversations and all projects.

## Troubleshooting

**No 🔌 icon in the compose bar**
- Quit Claude Desktop completely (⌘Q, not just close window) and reopen.
- Verify the `claude_desktop_config.json` path and JSON syntax. A trailing
  comma will silently break it.

**Claude never calls memory tools**
- The Project Instructions aren't being read. Double-check they're in the
  correct field and not just in chat history.
- Alternative: put the skill in **Custom Instructions** so it applies
  globally regardless of project.

**Tool calls fail with 401**
- Your MCP URL token is expired or was rotated. Go to MemPalace Cloud
  dashboard → Settings → regenerate your URL.

**Performance is slow on first use**
- The Python sidecar warm-starts on first request of the day. Subsequent
  calls should be <200ms.
