# MemPalace Cloud Plugin

Plugins and skill packs for [MemPalace Cloud](https://mempalace.cloud) — persistent AI memory as a service.

## What it does

1. **Connects your AI tool to MemPalace Cloud** via OAuth MCP (no API keys, no local setup)
2. **Teaches the AI to use memory proactively** — recall facts before answering, save learnings after tasks
3. **Everything reviewed** — captured memories land in your Inbox for approval before becoming permanent

## Installation

### Claude Code (plugin — recommended)

```bash
claude plugin add github:cschnatz/mempalace-cloud-plugin
```

Installs MCP connection + memory skill in one command. On first use, opens browser for OAuth login.

### Codex CLI (one-liner)

**macOS / Linux:**

```bash
curl -sL https://www.mempalace.cloud/skill-packs/install-codex.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://www.mempalace.cloud/skill-packs/install-codex.ps1 | iex
```

Adds the MCP server (with OAuth login) and downloads the memory skill into your project's `AGENTS.md`.

### Claude Desktop

```bash
claude mcp add mempalace-cloud --transport http https://api.mempalace.cloud/mcp -s user
```

Then add the memory instructions to your Project Settings. See [`skill-packs/claude-desktop.md`](skill-packs/claude-desktop.md) for the full instruction block.

### Cursor

Add to your MCP settings:

```json
{
  "mcpServers": {
    "mempalace-cloud": {
      "url": "https://api.mempalace.cloud/mcp"
    }
  }
}
```

Then add the memory instructions to Cursor Rules. See [`skill-packs/cursor.md`](skill-packs/cursor.md) for the full instruction block.

## What happens after install

Your AI gains 15+ memory tools (`mempalace_search`, `mempalace_kg_query`, `mempalace_diary_write`, etc.) and a skill that tells it:

- **Before responding** about a person, project, or past event → search memory first
- **After completing** a significant task or learning something → save it to memory
- **Never invent** — if memory has nothing, say so explicitly

Your memories persist across sessions, projects, and tools. Every conversation builds on the last.

## Repository structure

```
.claude-plugin/          # Claude Code plugin (used by `claude plugin add`)
  plugin.json
  marketplace.json
  .mcp.json
  skills/mempalace-cloud/SKILL.md

.codex-plugin/           # Codex CLI plugin (skill reference)
  plugin.json
  skills/mempalace-cloud/SKILL.md

skill-packs/             # Manual instructions for other tools
  claude-desktop.md      # Claude Desktop setup + instruction block
  cursor.md              # Cursor setup + rules block
```

## Requirements

- A MemPalace Cloud account (free tier at [mempalace.cloud](https://mempalace.cloud))
- One of: Claude Code, Codex CLI, Claude Desktop, or Cursor

## Verification

After installing, ask your AI: *"What do you know about my preferences?"*

It should call `mempalace_search` or `mempalace_kg_query` before answering. If it doesn't, check that the MCP server is connected and restart your tool.

## Troubleshooting

**AI says "I don't have memory tools"**
- Claude Code: Run `claude mcp list` — you should see `mempalace-cloud` with status `connected`
- Codex: Run `codex mcp list` — and check that `AGENTS.md` exists in your project with the Memory Protocol section
- If not listed, reinstall (plugin for Claude Code, install script for Codex)

**OAuth login doesn't complete**
- Make sure you have a MemPalace Cloud account at [mempalace.cloud](https://mempalace.cloud)
- Check that your browser opened the login page (pop-up blockers can interfere)

**Memories are captured but don't show up**
- New memories land in your Inbox first — check the [Inbox](https://mempalace.cloud/inbox)
- Items auto-approve after 24 hours if you don't review them

## Related

- [MemPalace](https://github.com/milla-jovovich/mempalace) — the open-source memory engine this service is built on
- [MemPalace Cloud](https://mempalace.cloud) — hosted service with OAuth, multi-device sync, and web UI

## License

MIT
