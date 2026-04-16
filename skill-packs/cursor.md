---
title: Cursor Skill Pack
tool: Cursor
installation_path: .cursorrules (project root) OR Cursor Settings → Rules
status: draft for Sprint 7
---

# Cursor — MemPalace Cloud Skill Pack

## Installation

Cursor supports two layers of custom rules: project-level (`.cursorrules`)
and user-level (Settings → Rules → User Rules). Both work for the memory
protocol.

### Step 1 — Add the MCP server

In Cursor Settings → MCP Servers → Add new:

```json
{
  "mcpServers": {
    "mempalace-cloud": {
      "url": "https://mcp.mempalace.cloud/u/YOUR_PERSONAL_TOKEN"
    }
  }
}
```

Replace `YOUR_PERSONAL_TOKEN` with the value from the dashboard.

Cursor will show a green dot next to "mempalace-cloud" once the server is
reachable.

### Step 2 — Add the rules

For **project-level**: create `.cursorrules` at the repo root with the block
below.

For **user-level**: Cursor Settings → Rules → User Rules → paste the block.

## The skill block (copy verbatim)

```
You have access to the MemPalace Cloud memory system via MCP tools prefixed
`mempalace_*`. Memory persists across all your sessions and across projects,
so you can remember what the user told you yesterday in a different repo.

MEMORY PROTOCOL (follow strictly):

1. BEFORE responding about anything involving a person, project, past
   decision, or past event: call `mempalace_kg_query` (for entities) or
   `mempalace_search` (semantic) first. Never guess — verify. If memory has
   nothing, say "I don't have anything in memory about that yet." and move
   on rather than inventing.

2. AFTER completing a non-trivial task or learning something new: call
   `mempalace_kg_add` (facts), `mempalace_diary_write` (narrative events),
   or `mempalace_add_drawer` (larger chunks). Examples of save-worthy:
   - Bug root causes (save BOTH the wrong guesses and the final fix)
   - Design decisions with rationale
   - User preferences discovered mid-conversation
   - Architectural choices for the current project
   - Lessons learned from a failed approach

3. Everything you write lands in the user's Inbox for review. They approve,
   edit, or reject within 24 hours. Write freely; don't self-censor.

4. When a search result has `status: pending`, mention it as unconfirmed:
   "Based on a note captured earlier (not yet reviewed): ..."

5. If you discover a previously recorded fact is wrong, call
   `mempalace_kg_invalidate` with the specific fact.

6. You may call `mempalace_status` at the start of a session to load the
   current protocol reminder and AAAK dialect spec.

When calling memory tools, prefer specific queries over vague ones. Instead
of `mempalace_search("code")`, use `mempalace_search("how we chose Zitadel
over Keycloak for the auth gateway")`.

## Team Vault Routing

Call `list_vaults` once per session to discover available vaults:
- Returns personal vault + all team vaults
- For personal memories: omit vault param (default: personal)
- For team knowledge: use `vault: "team_<uuid>"` from list_vaults
- Searching: default is `vault: "all"` (searches both personal and team vaults)
- Results include a `source` tag showing which vault they came from
```

## Verification

1. Open Cursor in a project with the `.cursorrules` in place.
2. Open the chat panel.
3. Ask: "What do you remember about this project?"
4. Cursor should call one of the `mempalace_*` tools before responding. You
   should see the tool invocation in the chat.

If no tool call happens, Cursor may have loaded the rule but decided the
query isn't memory-worthy. Try more explicit prompts:

- "Search your memory for anything about Postgres migrations"
- "Recall what we discussed yesterday"
- "What do you know about my preferences?"

## Troubleshooting

**MCP server shows a red dot in Cursor Settings**
- Verify the URL is correct (copy it fresh from the dashboard)
- Check your firewall isn't blocking Cursor's outbound HTTPS to
  `mcp.mempalace.cloud`
- Try the URL in a browser: `https://mcp.mempalace.cloud/u/YOUR_TOKEN` should
  return a JSON health message

**Cursor's "Compose" mode ignores the rule**
- Cursor's Compose is a different context from Chat and may not respect
  `.cursorrules`. Put the skill in User Rules (Cursor Settings → Rules →
  User Rules) for global coverage.

**Memory tools respond but retrieval is slow**
- First call of the day has a warm-up cost. Subsequent calls should be fast.

**Cursor auto-suggests wrong facts from memory**
- Call `mempalace_kg_invalidate` to supersede the wrong fact. Tell Cursor
  the specific wrong fact and ask it to invalidate it.

## Advanced

### Per-project overrides

You can add project-specific memory instructions to `.cursorrules` without
touching the global skill. Example:

```
[Inherit global memory protocol from User Rules]

Project-specific: This project uses Keycloak for auth, not Zitadel. If
memory has old notes claiming we use Zitadel here, treat them as stale —
those were from before the Feb 2026 migration. Call mempalace_kg_invalidate
to mark them superseded.
```

### Cursor Composer and Agent modes

Both modes respect the User Rules. Project `.cursorrules` are applied
inconsistently depending on Cursor version — prefer User Rules for critical
instructions like the memory protocol.
