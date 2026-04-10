---
name: mempalace-cloud
description: Persistent AI memory — recall facts before responding about people, projects, or past events. Save new learnings after completing tasks. Use when asked about memory, remembering, past conversations, or when encountering people/projects the user has discussed before.
allowed-tools: Bash, Read
---

# Memory Protocol (MemPalace Cloud)

You have access to a persistent, multi-session memory system through the
`mempalace_*` MCP tool surface. The memory spans all your sessions, projects,
and tools — it's the user's shared knowledge with you.

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

## Tool usage tips

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

## Status checks

If you're unsure whether the memory system is connected, call
`mempalace_status`. It returns the current palace state and a "protocol
reminder" string you should follow on every response.
