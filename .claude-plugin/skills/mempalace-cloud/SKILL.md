---
name: mempalace-cloud
description: Persistent AI memory — recall facts before responding about people, projects, or past events. Save new learnings after completing tasks. Use when asked about memory, remembering, past conversations, or when encountering people/projects the user has discussed before.
allowed-tools: Bash, Read
---

# Memory Protocol (MemPalace Cloud)

You have access to a persistent, multi-session memory system through the
`mempalace_*` MCP tool surface. The memory spans all your sessions, projects,
and tools — it's the user's shared knowledge with you.

## Connection & Token Handling

Before using memory tools, verify the connection works. If any MCP call
returns a token-expired error:

1. **Tell the user immediately:** "MemPalace MCP token is expired. Please
   run `/mcp` to re-authenticate."
2. **Do NOT silently fall back** to local file-based memory or any other
   storage. MemPalace Cloud is the single source of truth.
3. **After re-auth**, retry the original operation.

## When to recall (read from memory)

**Before responding about anything related to a person, project, past
decision, or past event**, call one of these first:

- `mempalace_kg_query` — structured facts about entities (people, projects, concepts)
- `mempalace_search` — semantic search of free-form memories
- `mempalace_kg_timeline` — chronological view of events
- `mempalace_traverse` — follow the palace graph from one room to another

If the memory has nothing about the topic, say so explicitly:
"I don't have anything in memory about that yet." NEVER invent facts.

If a search result is marked with `status: pending`, mention it as
provisional: "Based on a note captured earlier (not yet reviewed): ..."

### Search strategy

When searching, use MCP tools in this priority order:

1. `mempalace_search(query, wing, room)` — primary semantic search. Pass
   wing/room filters if the user mentions a specific domain.
2. `mempalace_kg_query(entity)` — if searching for facts about a specific
   entity (person, project, concept).
3. `mempalace_list_wings` / `mempalace_list_rooms` — discover what
   categories exist when you need to resolve a wing/room name.
4. `mempalace_traverse(room)` — walk the knowledge graph to explore
   connections from a specific room.
5. `mempalace_find_tunnels(wing1, wing2)` — find cross-wing connections
   when a topic spans multiple domains.

Present results with source attribution (wing, room) and similarity scores
when available. Offer to drill deeper or explore connections.

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

### Structuring memories: Wings, Rooms, and Drawers

The palace has a hierarchical structure. **Use it.** Don't dump everything
into a flat list — organize by wing and room so memories are findable later.

**Wings** are top-level categories (projects, people, domains):
- `wing_mempalace_cloud` — the MemPalace Cloud project
- `wing_christian` — facts about the user
- `wing_claude` — agent diary and session logs
- `wing_infrastructure` — servers, deployment, networking

**Rooms** are topics within a wing:
- `wing_mempalace_cloud/architecture` — design decisions
- `wing_mempalace_cloud/bugs` — bugs found and fixed
- `wing_christian/preferences` — work style, tool preferences

**When saving with `mempalace_add_drawer`**, always specify wing and room:

GOOD: `mempalace_add_drawer(wing="wing_mempalace_cloud", room="architecture",
      content="Chose Go gateway + Python sidecar because...")`
BAD:  `mempalace_add_drawer(content="some fact about the project")`

**When saving with `mempalace_kg_add`**, the entity name acts as the
organizational key. Use consistent entity names:

GOOD: `mempalace_kg_add(entity="mempalace-cloud", predicate="uses",
      object="Go gateway + Python sidecar")`
BAD:  `mempalace_kg_add(entity="project", predicate="tech", object="Go")`

**Discover existing structure first** with `mempalace_list_wings` and
`mempalace_list_rooms` before creating new wings. Reuse existing categories
to avoid fragmentation. Only create new wings/rooms when the topic genuinely
doesn't fit anywhere.

## Auto-Save Hooks

This plugin includes auto-save hooks that trigger automatically:

- **Stop hook** — every 15 human messages, you'll be asked to save key
  topics and decisions. Use `mempalace_diary_write` for narrative summaries
  and `mempalace_kg_add` for atomic facts.
- **PreCompact hook** — before context compaction, you'll be asked to save
  everything. Be thorough — after compaction, detailed context is lost.

When a hook triggers, prioritize saving over continuing the conversation.

## Tool usage tips

When calling memory tools, prefer descriptive queries over vague ones:

GOOD:  `mempalace_kg_query(entity="Alice")`
BAD:   `mempalace_kg_query(entity="things")`

GOOD:  `mempalace_search(query="how we chose Postgres over SQLite in the
       gateway")`
BAD:   `mempalace_search(query="database")`

## MCP Tools Reference (19)

### Palace (read)
- `mempalace_status` — palace overview: total drawers, wing/room counts
- `mempalace_list_wings` — all wings with drawer counts
- `mempalace_list_rooms` — rooms within a wing
- `mempalace_search` — semantic search with optional wing/room filter
- `mempalace_graph_stats` — palace graph connectivity overview

### Palace (write)
- `mempalace_add_drawer` — file content into a wing/room
- `mempalace_delete_drawer` — remove a drawer by ID

### Knowledge Graph
- `mempalace_kg_query` — query entity relationships with temporal validity
- `mempalace_kg_add` — add a fact (subject → predicate → object)
- `mempalace_kg_invalidate` — mark a fact as no longer true
- `mempalace_kg_timeline` — chronological timeline of facts
- `mempalace_kg_stats` — entity/triple/relationship overview

### Navigation
- `mempalace_traverse` — walk the palace graph from a room
- `mempalace_find_tunnels` — find rooms bridging two wings

### Agent Diary
- `mempalace_diary_write` — write session diary entry
- `mempalace_diary_read` — read recent diary entries

## Invalidation

If you discover a previously-recorded fact is wrong, call
`mempalace_kg_invalidate` with the specific fact. This doesn't delete the
fact — it marks it as superseded — but it stops future answers from citing
it.

## Architecture

    Wings (projects/people)
      └── Rooms (topics)
            └── Closets (summaries)
                  └── Drawers (verbatim memories)

    Halls connect rooms within a wing.
    Tunnels connect rooms across wings.
