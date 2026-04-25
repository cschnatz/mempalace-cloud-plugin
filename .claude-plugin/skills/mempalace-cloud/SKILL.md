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

---

## Team Vault Routing

Use `mempalace_list_vaults` to discover available vaults at session start.

### Discovery
Call `list_vaults` once per session. Returns personal vault + all team vaults with names and roles.

### Writing
- Personal preferences, private notes: omit `vault` param (default: personal)
- Team/project knowledge: `vault: "team_<uuid>"` (use UUID from list_vaults)
- When unsure, ask the user: "Store in [Team Name] or Personal?"

### Searching
- Default: `vault: "all"` searches personal + all team vaults
- Filter: `vault: "personal"` or `vault: "team_<uuid>"`
- Results include a `source` tag showing origin (personal or team name)

### Example
1. `list_vaults` returns `[Personal, "Backend Team" (team_abc-123)]`
2. `add_drawer(wing="project", room="api", content="...", vault="team_abc-123")`
3. `search(query="api design")` returns results from both vaults with source tags

---

## Discovery First: Read the Palace Before You Write

Before your first memory operation in a session, build a mental model of
the palace structure:

1. Call `mempalace_list_wings` — see which wings exist and how full each one is.
2. For any wing that's relevant to the current conversation, call
   `mempalace_list_rooms(wing)` to see its rooms.
3. Decide: does the current topic fit an existing wing/room, or does it need
   a new one?

Skip discovery only if you already explored the palace earlier in this same
session and nothing has changed.

**When to treat the palace as "flat" and trigger Bootstrap:** use these
operational checks rather than judgment calls.

- All existing wings have exactly one room each, OR
- The only wings present are `general` and/or `wing_<agent>` with no
  project/person/topic wings, OR
- `mempalace_graph_stats` reports `total_rooms` ≤ 2 **AND** no
  project/person/topic wings exist yet

Any of these → propose a Bootstrap plan to the user before writing.

Note: these checks identify a palace that needs structure. Once Bootstrap
has run and project/person/topic wings exist, none of these conditions
will match — a young palace with 2 rooms in `wing_mempalace_cloud` is
legitimate and will not re-trigger Bootstrap.

---

## Palace Structure

The palace has five primitives. Know them before you write.

```
  WING (project, person, or topic)
    └── ROOM (subject within that wing)
          ├── DRAWER  (verbatim content — what you save)
          └── CLOSET  (AAAK-compressed auto-summary of the room — hands-off)

  HALL   = connection between rooms inside the same wing (automatic)
  TUNNEL = connection between rooms across different wings (automatic)
```

Drawers are the primary save target. Closets are a read-only side-channel
maintained by the palace — you never create or read them directly.

### Wings — one per project, person, or major topic

Four archetypes cover most use cases:

**Project wings** — one per distinct codebase, product, or initiative.
- Pattern: `wing_<project-slug>` (e.g. `wing_mempalace_cloud`, `wing_swissnet`)
- Typical rooms: `architecture`, `decisions`, `bugs`, `features`,
  `deployment`, `roadmap`, `sessions`

**Person wings** — one per person whose context matters.
- Pattern: `wing_<person-slug>` (e.g. `wing_christian`)
- Typical rooms: `preferences`, `role`, `background`, `tools`, `workflow`

**Self wings** — one for the AI agent's own diary and reflections.
- Pattern: `wing_<agent>` (e.g. `wing_claude`, `wing_codex`)
- Typical rooms: `diary`, `lessons_learned`, `mistakes`, `techniques`

**Topic wings** — durable knowledge domains not tied to one project or person.
- Pattern: `wing_<topic-slug>` (e.g. `wing_typescript`, `wing_oauth`,
  `wing_architecture_patterns`)
- Typical rooms: `patterns`, `gotchas`, `references`, `decisions`
- Use when the same knowledge applies across many projects.

### Rooms — subjects within a wing

- Name rooms in `snake_case`: `architecture`, `lessons_learned`, `api_design`
- Reuse existing rooms aggressively — don't create a new room for one-off
  content. Wait for a pattern of 3+ related drawers before splitting.
- A room is "recurring topic", not "one note".

### Closets — automatic, don't touch

Closets are AAAK-compressed summaries of a room, maintained by MemPalace
automatically. You never create or read closets directly. Your job is to
file drawers correctly; the palace compresses them for you.

### Halls and Tunnels — cross-room navigation

- **Halls** connect rooms inside the same wing. They emerge automatically.
- **Tunnels** connect rooms across different wings. Use
  `mempalace_find_tunnels(wing1, wing2)` only when you have reason to
  believe a cross-wing connection exists — not as a routine discovery
  step, and not on every session start.

Think about tunnels when:
- A user's preferences (person wing) shape a project decision (project wing)
- A bug pattern from project A applies to project B
- A lesson learned (self wing) is specific to a particular project

Tunnels can be discovered or created explicitly:
- `mempalace_find_tunnels(wing_a, wing_b)` — discover natural bridges
  based on content similarity.
- `mempalace_create_tunnel(source_wing, source_room, target_wing,
  target_room, label)` — create an explicit tunnel. Always include a
  `label` explaining why the connection exists.

**When to create tunnels:**
- A user's preferences shaped a project decision
- A bug pattern from project A applies to project B
- An architecture decision in one project mirrors another

**When NOT to:** Don't tunnel speculatively. Search first, tunnel if recurring.

---

## Palace Bootstrap — when the palace is empty or flat

If discovery reveals no wings (or only `general` with a single dump), stop
and establish proper structure before saving new memories.

**Flow:**

1. Identify which wings the current context actually needs. Usually 1–3:
   - The current project → project wing
   - The user → person wing
   - Your session/agent diary → self wing
2. Propose the wings to the user in one line:
   "I'd like to set up these wings: `wing_mempalace_cloud` (project),
   `wing_christian` (person), `wing_claude` (me). Okay to proceed?"
3. On confirm, create the structure by making your first saves with the
   proposed wing + a sensible starter room. Wings and rooms are created
   implicitly on first save — no explicit create tool needed.
4. After creating initial wings, check for local session files:
   - Claude Code: does `~/.claude/projects/` exist and contain `.jsonl` files?
   - Codex CLI: does `~/.codex/sessions/` exist?
   If yes, offer: "I also found your [Claude Code/Codex] session history.
   Want me to scan it for memories to import into your new palace?"
   On confirm, follow the Session Mining flow above.

Do Bootstrap + mining offer once per palace, not once per session.

---

## When to recall (read from memory)

**Before responding about anything related to a person, project, past
decision, or past event**, pick the right lookup tool for the question type:

- **Named entity** (person, company, product)? → `mempalace_kg_query(entity)`
  FIRST. Authoritative for proper-noun lookups, always reliable.
  - Use `as_of` param for point-in-time queries: `mempalace_kg_query(entity="auth_gateway", as_of="2026-03-01")`
  - Use `direction` to narrow results: `"outgoing"` (what X relates to), `"incoming"` (what relates to X), `"both"` (default)
- **Narrative / semantic question** (theme, topic) → `mempalace_search` —
  semantic search of free-form memories.
  - `mempalace_search` accepts an optional `context` param for background context (logged for future search augmentation)
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

### Search strategy

When searching, use MCP tools in this priority order:

1. `mempalace_search(query, wing, room)` — primary semantic search. Pass
   wing/room filters if the user mentions a specific domain. **Narrowing by
   wing/room is the main win** — don't search globally if you can filter.
2. `mempalace_kg_query(entity)` — facts about a specific entity
   (person, project, concept).
3. `mempalace_list_wings` / `mempalace_list_rooms` — discover what
   categories exist when you need to resolve a wing/room name.
4. `mempalace_traverse(room)` — walk the knowledge graph to explore
   connections from a specific room.
5. `mempalace_find_tunnels(wing1, wing2)` — find cross-wing connections
   when a topic spans multiple domains.

Present results with source attribution (wing, room) and similarity scores.
Offer to drill deeper or explore connections.

---

## When to save (write to memory)

**After completing a significant task or learning something new**, save it.
But follow the Save Decision Flow every time — don't dump.

Memory-worthy events include:

- A bug you finally tracked down (save root cause AND wrong guesses)
- A design decision with rationale
- A new fact about a team member's preferences or context
- A milestone reached
- A lesson learned you'll want to apply next time

Everything lands in the user's Inbox first. They review it before it becomes
permanent. If untouched for 24h, items auto-approve. Your job is to capture
thoughtfully, not to filter.

### Save Decision Flow

Every save must answer three questions **in order**:

**1. Which wing?** Match by topic.
- Fact about the user → person wing (e.g. `wing_christian`)
- Decision about a project → project wing (e.g. `wing_mempalace_cloud`)
- Session summary or self-reflection → self wing (e.g. `wing_claude`)
- Cross-cutting knowledge (not tied to one project) → topic wing
  (e.g. `wing_oauth`)
- Topic spans two existing wings → pick the primary one; consider creating
  a tunnel with `mempalace_create_tunnel` if the cross-wing link is recurring

**2. Which room?** Match by subject.
- List rooms for the chosen wing first: `mempalace_list_rooms(wing)`
- Reuse if a good match exists
- Create a new room only if the topic is recurring (pattern of 3+ related
  drawers), not one-off
- Name new rooms in `snake_case`

**Creation gate — read this every save:**

If Q1 or Q2 would require a wing or room that does not currently exist,
**stop and confirm with the user before saving**. One line is enough:
"This needs a new `wing_oauth/patterns` room — okay to create it?"

This applies equally to first save of a session and to any later save.
Silent creation (`add_drawer` to a non-existent wing) is an anti-pattern
even if the Bootstrap phase ran earlier.

**3. Which tool?**
- `mempalace_add_drawer(wing, room, content)` — verbatim content
  (decisions + reasoning, debugging sessions, design discussions).
  `wing` and `room` are **required** — always specify both.
  - Use `source_file` for provenance when the memory comes from a specific file.
- `mempalace_kg_add(entity, predicate, object)` — atomic facts that may
  change over time (preferences, roles, current tech stack)
  - Use `valid_from` when you know when a fact became true: `mempalace_kg_add(entity="auth", relationship="uses", target="zitadel", valid_from="2026-04-09")`
  - Use `source_closet` to link a fact back to a specific drawer for provenance.
- `mempalace_diary_write(content)` — narrative session summaries (files
  automatically to `wing_<agent>/diary`)

### Anti-patterns — do NOT do these

- ❌ Save everything to `wing_claude/diary` regardless of topic — that's a
  dump, not a palace.
- ❌ Use generic names like `general`, `stuff`, `notes`, `misc`.
- ❌ Create a new wing when an existing one fits.
- ❌ Create a new room for a single one-off memory.
- ❌ Skip discovery and guess the wing/room.
- ❌ Silently create wings without telling the user.

### Do this instead

- ✅ Call `list_wings` + `list_rooms` before the first save of a session.
- ✅ Propose new wings to the user before creating them.
- ✅ Reuse existing rooms aggressively.
- ✅ Match content topic to a well-named room.
- ✅ Create new rooms only when a pattern of 3+ related drawers emerges.

### Restructure Flow — when an existing wing or room no longer fits

As a palace grows, you may notice:
- A wing's drawers span two distinct topics (split signal)
- A room accumulates 20+ drawers with clearly separable subtopics (split signal)
- Two small rooms overlap heavily (merge signal)

**How to handle it:**

1. Do not rewrite existing drawers. Restructure is forward-looking only.
2. Propose the change to the user in one line:
   "I think `wing_mempalace_cloud/architecture` should split into
   `architecture_backend` and `architecture_frontend` — new saves would
   go to the split rooms, old ones stay put. Okay?"
3. On confirm, route **future** saves to the new structure. Old drawers
   remain in place unless the user asks to migrate.
4. Never silently split or merge. Always confirm.

---

## Auto-Save Hooks

This plugin includes auto-save hooks that trigger automatically:

- **Stop hook** — every 15 human messages, you'll be asked to save key
  topics and decisions. Use `mempalace_diary_write` for narrative summaries
  and `mempalace_kg_add` for atomic facts. Follow the Save Decision Flow
  even when triggered by a hook.
- **PreCompact hook** — before context compaction, you'll be asked to save
  everything. Be thorough — after compaction, detailed context is lost.

When a hook triggers, prioritize saving over continuing the conversation.

---

## Session Mining — Import Existing Conversations

You can help users import their existing Claude Code or Codex CLI session
histories into MemPalace. This populates the palace with decisions,
insights, and facts from past conversations.

### When to Offer Mining

**After Bootstrap (empty palace):** Once you've set up initial wings,
check for local sessions:
- Claude Code: `~/.claude/projects/` directory
- Codex CLI: `~/.codex/sessions/` directory

If sessions exist, offer: "I see you have [Claude Code/Codex] sessions.
Want me to scan them for memories to import?"

**On explicit request:** Users may ask in natural language:
- "mine my sessions", "mine meine Sessions"
- "import my history", "importiere meine History"
- "scan my conversations", "durchsuche meine Konversationen"
- "bootstrap my palace", "fill my palace"

### Mining Flow

1. **Detect platform:** Check which tool you are:
   - Claude Code → scan `~/.claude/history.jsonl` + `~/.claude/projects/`
   - Codex CLI → scan `~/.codex/history.jsonl` + `~/.codex/sessions/`

2. **Ask time range:** "How far back should I scan? (Default: 30 days)"

3. **Scan history index:** Read `history.jsonl` to identify sessions.
   Group by session ID, skip sessions with fewer than 5 messages.

4. **Deep-read sessions:** For each qualifying session, read the full
   JSONL file and extract memories.

5. **Extraction rules — what to extract:**
   - Decisions and rationale ("We chose X because...")
   - Technical insights and discoveries
   - Facts about people, projects, preferences
   - Architecture patterns and design choices
   - Solved bugs with root cause
   - Lessons learned

6. **Extraction rules — what to IGNORE:**
   - Tool call output (Read, Glob, Grep results)
   - Code diffs and file listings
   - Stack traces and error logs
   - Generic explanations
   - Passwords, API keys, tokens, secrets, .env contents

7. **Quality:** Each memory must be an atomic, standalone fact. Target
   1-5 memories per session, not 1 per message. Summarize related points.
   Max 2000 characters per memory.

8. **Show preview:** Before importing, show:
   "Found: N memories from M sessions. Here are 5 examples:"
   [show 5 representative memories]
   "Import all? They'll appear in your Inbox for review."

9. **Import:** On user confirmation, call `mempalace_mine_batch` with
   the extracted memories. Report the results:
   "Imported X, skipped Y duplicates. Review them in your Inbox."

### Platform-Specific Parsing

**Claude Code** (`~/.claude/projects/*/<sessionId>.jsonl`):
- Lines are `{role, content}` objects
- Extract from `role: "user"` and `role: "assistant"` messages
- `role: "tool"` lines are tool output — skip

**Codex CLI** (`~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`):
- Lines have `type` field: `session_meta`, `response_item`, `event_msg`, `turn_context`
- Extract from `response_item` with `role: "user"` or `role: "assistant"`
- `session_meta` has project context (`cwd`, git info) — useful for classification
- Skip `event_msg` and `turn_context` (metadata only)
- Also check `~/.codex/archived_sessions/` for older sessions

---

## Tool usage tips

When calling memory tools, prefer descriptive queries over vague ones:

GOOD:  `mempalace_kg_query(entity="Christian")`
BAD:   `mempalace_kg_query(entity="user")`

GOOD:  `mempalace_search(query="why we chose Go gateway over Node", wing="wing_mempalace_cloud", room="architecture")`
BAD:   `mempalace_search(query="gateway")`

Always pass `wing` and `room` filters when you know them. Unfiltered search
on a large palace is noisy and slow.

---

## MCP Tools Reference (30)

### Palace (read)
- `mempalace_status` — palace overview: total drawers, wing/room counts
- `mempalace_list_wings` — all wings with drawer counts
- `mempalace_list_rooms` — rooms within a wing
- `mempalace_search` — semantic search with optional wing/room filter
- `mempalace_graph_stats` — palace graph connectivity overview
- `mempalace_get_taxonomy` — full taxonomy: wing → room → drawer count
- `mempalace_get_aaak_spec` — get the AAAK compressed memory format spec
- `mempalace_check_duplicate` — check if content already exists (similarity threshold)

### Palace (write)
- `mempalace_add_drawer` — file content into a wing/room
- `mempalace_get_drawer` — fetch a single drawer by ID with full content
- `mempalace_list_drawers` — list drawers with pagination and wing/room filter
- `mempalace_update_drawer` — update drawer content and/or metadata
- `mempalace_delete_drawer` — remove a drawer by ID
- `mempalace_mine_batch` — bulk-import mined session memories (dedup, classify, secret scan)

### Knowledge Graph
- `mempalace_kg_query` — query entity relationships with temporal validity
- `mempalace_kg_add` — add a fact (subject → predicate → object)
- `mempalace_kg_invalidate` — mark a fact as no longer true
- `mempalace_kg_timeline` — chronological timeline of facts
- `mempalace_kg_stats` — entity/triple/relationship overview

### Navigation
- `mempalace_traverse` — walk the palace graph from a room
- `mempalace_find_tunnels` — find rooms bridging two wings

### Tunnels
- `mempalace_create_tunnel` — create cross-wing tunnel between two locations
- `mempalace_list_tunnels` — list all explicit tunnels, optionally by wing
- `mempalace_delete_tunnel` — delete a tunnel by ID
- `mempalace_follow_tunnels` — follow tunnels from a room to connected wings

### Agent Diary
- `mempalace_diary_write` — write session diary entry (goes to wing_<agent>/diary)
- `mempalace_diary_read` — read recent diary entries

### Utility
- `mempalace_hook_settings` — get/set hook behavior (silent_save, desktop_toast)
- `mempalace_memories_filed_away` — check recent palace checkpoint status
- `mempalace_reconnect` — force reconnect to palace database after external changes

---

## Invalidation

If you discover a previously-recorded fact is wrong, call
`mempalace_kg_invalidate` with the specific fact. This doesn't delete the
fact — it marks it as superseded — but it stops future answers from citing
it. Use `ended` (YYYY-MM-DD) to set a specific end date instead of today.
Useful when a user changes preferences, migrates tech stack, or you
learn a past assumption was wrong.
