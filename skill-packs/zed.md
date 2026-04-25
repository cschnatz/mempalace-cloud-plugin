---
title: Zed Skill Pack
tool: Zed
installation_path: Zed → Settings → Assistant → Custom Instructions
status: draft for Sprint 7
---

# Zed — MemPalace Cloud Skill Pack

## Installation

### Step 1 — Add the MCP server

Zed's assistant supports external context servers via MCP (as of Zed 0.155+).

Edit `~/.config/zed/settings.json` (macOS/Linux) or `%APPDATA%\Zed\settings.json` (Windows) and add:

```json
{
  "assistant": {
    "context_servers": {
      "mempalace-cloud": {
        "source": "http",
        "url": "https://mcp.mempalace.cloud/u/YOUR_PERSONAL_TOKEN"
      }
    }
  }
}
```

Replace `YOUR_PERSONAL_TOKEN` with the value from the MemPalace Cloud
dashboard.

Reload Zed: cmd/ctrl+shift+p → "zed: reload". The assistant should now have
access to the `mempalace_*` tools.

### Step 2 — Add the memory protocol to your default assistant

Zed Settings → Assistant → **Custom Instructions** → paste the block below.

## The skill block (copy verbatim)

```
You have the MemPalace Cloud memory system available via MCP tools prefixed
mempalace_*. Memory persists across Zed sessions, other editors, and
machines — it's the user's shared long-term memory across every AI tool.

MEMORY PROTOCOL:

Before responding about any person, project, past decision, or past event,
pick the right lookup tool:

- Named entity (person, company, product) → mempalace_kg_query(entity) FIRST.
  Authoritative for proper-noun lookups, always reliable.
- Narrative / semantic question (theme, topic) → mempalace_search.
- Search returned only generic drawers? → fall back to
  mempalace_list_drawers(wing, room) to enumerate directly. Proper-noun
  queries are unreliable in semantic search (upstream bug); kg_query and
  list_drawers are not affected.

Never invent. If all lookups are empty, say "I don't have anything in
memory about that yet" and ask the user to fill in the context or move on.

After completing meaningful work or learning something: save it.
- mempalace_kg_add for atomic facts
- mempalace_diary_write for narrative events
- mempalace_add_drawer for larger chunks

Memory-worthy: bugs tracked down (with wrong guesses), design decisions,
user preferences, milestones, lessons.

All captures land in the user's Inbox for review. They auto-approve after
24 hours. Write freely — don't self-filter.

When search results have `status: pending`, mark them as unconfirmed:
"Based on an unreviewed note from earlier: ..."

If a previously recorded fact is wrong, call mempalace_kg_invalidate.

At the start of a session, optionally call mempalace_status to refresh the
protocol and load the AAAK dialect spec.

Prefer specific queries over vague ones.

TEAM VAULT ROUTING:

Call mempalace_list_vaults once per session. For personal memories, omit the
vault param (defaults to personal). For team knowledge, use vault:
"team_<uuid>" (from list_vaults). Search defaults to vault: "all" (both
personal and all team vaults). Results include a source tag showing origin.
```

## Verification

Open the Zed assistant panel (cmd/ctrl+?). Ask: "What do you know about my
recent work?"

You should see the assistant call a `mempalace_*` tool. Zed displays tool
calls inline in the chat.

## Troubleshooting

**The mempalace_* tools don't appear in the tool list**
- Check `~/.config/zed/settings.json` syntax (no trailing commas).
- Restart Zed (cmd/ctrl+q, not just close window).
- Check Zed's log: `cmd/ctrl+shift+p` → "zed: open log".

**Tool calls fail with 401**
- Token expired or rotated. Regenerate from the MemPalace Cloud dashboard
  and update `settings.json`.

**Assistant is slow to respond on first use**
- The Python sidecar is warming up. Subsequent responses should be fast.

## Zed-specific notes

- Zed's assistant supports both "inline" completions (tab-to-accept) and
  "chat" interactions (assistant panel). The memory protocol activates in
  both, but chat is more reliable for tool calls.
- Zed has strong type/compile hints available via its built-in language
  servers. The assistant will use those in combination with memory — e.g.
  "based on the type definition AND what we noted yesterday, ..."
- Zed 0.156+ supports per-project `.zed/settings.json` overrides. You can
  use this to add project-specific memory instructions without touching the
  global config.
