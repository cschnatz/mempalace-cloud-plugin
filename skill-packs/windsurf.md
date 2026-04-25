---
title: Windsurf Skill Pack
tool: Windsurf (Codeium IDE)
installation_path: Windsurf → Settings → Cascade → Global Rules
status: draft for Sprint 7
---

# Windsurf — MemPalace Cloud Skill Pack

## Installation

Windsurf's AI (Cascade) supports MCP servers and custom rules.

### Step 1 — Add the MCP server

Windsurf → Settings (⌘,) → **Cascade** → **MCP** → **Add server**.

Configuration:
- **Name**: `mempalace-cloud`
- **Type**: HTTP
- **URL**: `https://mcp.mempalace.cloud/u/YOUR_PERSONAL_TOKEN`

Save. Cascade should show the server as connected.

Alternatively, edit `~/.codeium/windsurf/mcp_config.json`:

```json
{
  "mcpServers": {
    "mempalace-cloud": {
      "url": "https://mcp.mempalace.cloud/u/YOUR_PERSONAL_TOKEN"
    }
  }
}
```

### Step 2 — Add the memory protocol to Global Rules

Windsurf → Settings → Cascade → **Global Rules** → paste the block below.

For **project-level** rules, create `.windsurfrules` at the repo root (same
format).

## The skill block (copy verbatim)

```
You have the MemPalace Cloud memory system via MCP tools prefixed
mempalace_*. This memory is the user's cross-session, cross-tool, cross-
project long-term memory. It's shared with every other AI tool they use.

MEMORY PROTOCOL (non-negotiable):

Before answering any question involving a person, project, past decision,
or past event, pick the right lookup tool:

- Named entity (person, company, product) → mempalace_kg_query(entity) FIRST.
  Authoritative for proper-noun lookups, always reliable.
- Narrative / semantic question (theme, topic) → mempalace_search.
- Search returned only generic drawers? → fall back to
  mempalace_list_drawers(wing, room) to enumerate directly. Proper-noun
  queries are unreliable in semantic search (upstream bug); kg_query and
  list_drawers are not affected.

Never invent. If all lookups have nothing on the topic, say so:
"I don't have anything in memory about that yet."

After completing work or learning something new, save it:
- mempalace_kg_add — atomic facts ("Alice prefers Python for ML")
- mempalace_diary_write — narrative events ("2026-04-08: shipped the new
  billing flow after the Stripe tax issue")
- mempalace_add_drawer — larger knowledge chunks

Memory-worthy events:
- Bugs tracked down (save wrong guesses AND final fix — both valuable)
- Design decisions with rationale
- Refactors and why we chose them
- User preferences discovered mid-session
- Architectural constraints
- Lessons learned

Captures land in the user's Inbox for review. Auto-approve after 24 hours.
Write freely — let the user filter, not you.

When a search result is marked `status: pending`: "Based on an unreviewed
note captured earlier: ..."

If you discover a previously recorded fact is wrong, call
mempalace_kg_invalidate with the specific fact.

Optionally at session start, call mempalace_status to refresh the protocol
and load the AAAK dialect spec.

Be specific when querying. `mempalace_search("how we solved the Stripe tax
handling edge case for DE customers")` beats `mempalace_search("tax")`.

TEAM VAULT ROUTING:

Call mempalace_list_vaults once per session. For personal memories, omit the
vault param (defaults to personal). For team knowledge, use vault:
"team_<uuid>" (from list_vaults). Search defaults to vault: "all" (personal
+ all team vaults). Results include source tag.
```

## Verification

Open Cascade chat in Windsurf. Ask: "What do you remember about this
codebase?"

Cascade should call a `mempalace_*` tool before responding.

## Troubleshooting

**Cascade doesn't list the mempalace_* tools**
- Verify the MCP config JSON syntax.
- Restart Windsurf after adding the server.
- Check the Cascade logs for MCP connection errors.

**Memory tool calls fail with 401**
- Token expired or rotated. Regenerate in the dashboard and update the
  config.

**Cascade is overly chatty about memory**
- You can shorten the skill block to just the imperatives and remove the
  explanatory commentary. The core instructions are:
  > Before answering about past events: call mempalace_search or
  > mempalace_kg_query first. Never invent. Save significant work
  > automatically via mempalace_kg_add / mempalace_diary_write.

## Windsurf-specific notes

- Windsurf's Cascade supports Agent mode where it can autonomously run
  multi-step tasks. Make sure `mempalace_*` tools are on the allowed tools
  list so Cascade can call them without asking permission every time.
- Windsurf has a "Memories" feature separate from our MemPalace — don't
  confuse the two. Windsurf's built-in memory is local and Codeium-specific;
  it doesn't replace MemPalace Cloud.
