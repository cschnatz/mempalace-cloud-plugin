---
title: Cline Skill Pack
tool: Cline (VS Code extension)
installation_path: Cline extension → Settings → Custom Instructions
status: draft for Sprint 7
---

# Cline — MemPalace Cloud Skill Pack

## Installation

### Step 1 — Add the MCP server

Open Cline in VS Code → click the ⚙️ (settings gear) → **MCP Servers** →
**Add new server**.

Fill in:
- **Name**: `mempalace-cloud`
- **URL or command**: `https://mcp.mempalace.cloud/u/YOUR_PERSONAL_TOKEN`
- **Type**: HTTP

Save. Cline should show the server as connected with a green indicator.

### Step 2 — Add the memory protocol to Custom Instructions

Cline → Settings → **Custom Instructions** → paste the block below.

## The skill block (copy verbatim)

```
You have access to the MemPalace Cloud memory system via MCP tools prefixed
mempalace_*. This memory persists across VS Code sessions, other AI tools,
and even other machines — it's the user's shared second brain.

MEMORY PROTOCOL:

Before answering ANY question about a person, project, past decision, or
past event, call mempalace_kg_query (structured facts) or mempalace_search
(semantic) first. Do not invent. If memory is empty on the topic, say so
plainly: "I don't have anything in memory about that yet."

After completing significant work or learning something new, save it:
- mempalace_kg_add for atomic facts
- mempalace_diary_write for narrative events
- mempalace_add_drawer for larger chunks of knowledge

Save-worthy events include:
- A bug you tracked down (save the wrong guesses too — they're valuable)
- A design decision with reasoning
- A refactor you chose and why
- A preference the user expressed
- A milestone (shipped feature, first paying customer, etc.)

Your captures land in the user's Inbox for review. They approve, edit, or
reject. Unreviewed items auto-approve after 24 hours. Write freely; the
user filters, not you.

When a search result is marked `status: pending`, mention it as
provisional: "Based on a note captured earlier (not yet reviewed): ..."

If you find a previously recorded fact that is now wrong, call
mempalace_kg_invalidate to mark it superseded. Don't silently overwrite.

You may start each new session by calling mempalace_status to refresh the
current protocol reminder and load the AAAK dialect spec.

Be specific when querying: prefer mempalace_search("how we solved the
Chroma PersistentClient production issue") over mempalace_search("Chroma").

TEAM VAULT ROUTING:

Call mempalace_list_vaults once per session to discover available vaults.
For personal memories, omit the vault param (defaults to personal). For team
knowledge, use vault: "team_<uuid>" (from list_vaults). Search defaults to
vault: "all" (personal + all team vaults). Results include a source tag.
```

## Verification

Open a chat in Cline and ask: "What do you remember about this project?"
Cline should call `mempalace_search` or `mempalace_kg_query` before
responding. Check the tool-call pane for confirmation.

## Troubleshooting

**Cline doesn't show the MCP server as connected**
- Make sure the URL is complete with the `/u/YOUR_TOKEN` path.
- Restart VS Code after adding the server.
- Check Cline's output panel for MCP connection errors.

**Cline calls the memory tools but returns "no results"**
- Normal on a fresh account. Capture a few memories by explicitly asking
  Cline to remember things, then query again.

**Custom Instructions get truncated in Cline**
- Cline has a character limit on the Custom Instructions field. If the block
  above is truncated, shorten the explanatory comments and keep only the
  instruction imperatives.

**Memory tools time out**
- The Python sidecar warm-starts on the first call of the day. Subsequent
  calls should be <200ms. If timeouts persist, check the MemPalace Cloud
  status page.

## Cline-specific notes

- Cline supports tool approval modes. For the memory protocol to work
  smoothly, consider whitelisting `mempalace_*` tools so you don't have to
  approve each memory read/write manually.
- Cline can auto-run commands in the terminal. The memory protocol does NOT
  require any terminal commands — it's all MCP tool calls over HTTP.
