---
title: Claude Code Skill Pack
tool: Claude Code
installation_path: ~/.claude/CLAUDE.md (user-global) OR ./CLAUDE.md (project)
status: draft for Sprint 7
---

# Claude Code — MemPalace Cloud Skill Pack

## Installation (two options)

### Option 1 — User-global (recommended)

Append the block below to your `~/.claude/CLAUDE.md`. Memory works for every
Claude Code session on this machine.

### Option 2 — Per-project

Create a `CLAUDE.md` at the root of a specific project and paste the block
below. Memory only applies when Claude Code is run inside that project.

Mix-and-match is fine — project-level CLAUDE.md layers on top of the
user-global one.

## The skill block (copy verbatim)

```markdown
# Memory Protocol (MemPalace Cloud)

You have access to a persistent, multi-session memory system through the
`mempalace_*` MCP tool surface. The memory spans all your sessions, projects,
and tools — it's the user's shared knowledge with you.

## When to recall (read from memory)

**Before responding about anything related to a person, project, past
decision, or past event**, pick the right lookup tool for the question type:

- **Named entity** (person, company, product)? → `mempalace_kg_query(entity)`
  FIRST. Authoritative for proper-noun lookups, always reliable.
- **Narrative / semantic question** (theme, topic) → `mempalace_search` —
  semantic search of free-form memories.
- **Search returned only generic drawers?** → Fall back to
  `mempalace_list_drawers(wing, room)` to enumerate directly. Proper-noun
  queries are unreliable in semantic search (upstream bug); `kg_query`
  and `list_drawers` are not affected.
- `mempalace_kg_timeline` — chronological view of events.
- `mempalace_traverse` — follow the palace graph from one room to another.

If the memory has nothing about the topic, say so explicitly:
"I don't have anything in memory about that yet." NEVER invent facts.

If a search result is marked with `status: pending`, mention it as
provisional: "Based on a note captured earlier (not yet reviewed): ..."

## When to save (write to memory)

**After completing a significant task or learning something new**, call:

- `mempalace_kg_add` — for atomic facts ("Alice prefers Python over TypeScript")
- `mempalace_diary_write` — for narrative events ("2026-04-08: Shipped the
  new auth flow after the Zitadel free-tier issue")
- `mempalace_add_drawer` — for larger knowledge chunks you want to retrieve
  later by semantic search

Memory-worthy events include:

- A bug you finally tracked down (save the root cause AND the wrong guesses
  along the way — both are valuable)
- A design decision with rationale ("we chose Postgres over SQLite because ...")
- A new fact about a team member's preferences or context
- A milestone reached
- A lesson learned that you'll want to apply next time

Write freely. Everything lands in the user's Inbox first and they review
it before it becomes permanent. If the user doesn't touch the Inbox, items
auto-approve after 24 hours. Your job is to capture, not to filter.

## Tool descriptions

When calling memory tools, prefer descriptive queries over vague ones:

GOOD:  `mempalace_kg_query(entity="Alice", context="work preferences")`
BAD:   `mempalace_kg_query(entity="things")`

GOOD:  `mempalace_search(query="how we chose Postgres over SQLite in the
       gateway", limit=5)`
BAD:   `mempalace_search(query="database")`

## Invalidation

If you discover a previously-recorded fact is wrong, call
`mempalace_kg_invalidate` with the specific fact. This doesn't delete the
fact — it marks it as superseded — but it stops future answers from citing
it.

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

## Status checks

If you're unsure whether the memory system is connected, call
`mempalace_status`. It returns the current palace state and a "protocol
reminder" string you should follow on every response.
```

## New Parameters (v1.4.0)

- `mempalace_add_drawer`: `wing` and `room` are now **required**. Always specify both.
- `mempalace_kg_add`: Use `valid_from` (YYYY-MM-DD) for temporal facts.
- `mempalace_kg_query`: Use `as_of` for point-in-time queries, `direction` for outgoing/incoming/both.
- `mempalace_kg_invalidate`: Use `ended` to set a specific end date.
- `mempalace_search`: Optional `context` param for background context (logged for future use).

After updating, reconnect MCP (`/mcp` or restart client) to load new tool schemas.

## Verification

After installing, open Claude Code and ask: "What do you know about my
preferences?" Claude should call `mempalace_kg_query` or `mempalace_search`
before answering — you'll see the tool-call in the sidebar or log.

If Claude doesn't call any memory tool, the skill pack isn't loaded or the
MCP URL isn't configured. Troubleshoot:

1. Verify `~/.claude/CLAUDE.md` or `./CLAUDE.md` contains the block
2. Verify `~/.config/claude-code/config.json` (or equivalent) has the MCP
   server entry with your personal URL from the MemPalace Cloud dashboard
3. Restart Claude Code
4. Try again with: "What do you remember about me?"

## Troubleshooting

**Claude says "I don't have memory tools"**
- The MCP URL is not configured. Go to your MemPalace Cloud dashboard →
  Settings → Tools → copy the URL and paste it into your Claude Code MCP
  config.

**Claude calls `mempalace_search` but returns nothing**
- Normal on a fresh account. Memory builds up over time.
- Try the "remember this" flow: tell Claude "please remember I prefer TypeScript
  over Python for web projects" and then ask about your preferences in a new
  session.

**Memories are captured but never show in the Memory Browser**
- Check the Inbox — captures are pending until you approve them.
- 24h auto-approval means anything older than yesterday should have moved
  to approved automatically. If not, check the MemPalace Cloud status page
  for cron issues.
