# MemPalace Cloud Plugin

Claude Code plugin for [MemPalace Cloud](https://mempalace.cloud) — persistent AI memory as a service.

## What it does

1. **Connects Claude Code to MemPalace Cloud** via OAuth MCP (no API keys, no local setup)
2. **Teaches Claude to use memory proactively** — recall facts before answering, save learnings after tasks
3. **Everything reviewed** — captured memories land in your Inbox for approval before becoming permanent

## Installation

```bash
claude plugin add github:cschnatz/mempalace-cloud-plugin
```

On first use, Claude Code will open a browser window for OAuth login. After that, memory just works.

## What happens after install

Claude Code gains 15+ memory tools (`mempalace_search`, `mempalace_kg_query`, `mempalace_diary_write`, etc.) and a skill that tells it:

- **Before responding** about a person, project, or past event → search memory first
- **After completing** a significant task or learning something → save it to memory
- **Never invent** — if memory has nothing, say so explicitly

Your memories persist across sessions, projects, and tools. Every conversation builds on the last.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- A MemPalace Cloud account (free tier available at [mempalace.cloud](https://mempalace.cloud))

## How it works

The plugin registers an HTTP MCP server pointing at `api.mempalace.cloud/mcp`. Authentication uses OAuth 2.0 with PKCE — Claude Code handles the browser-based login flow automatically.

The memory protocol skill (`SKILL.md`) is loaded into Claude's context, teaching it when and how to call memory tools. No local Python or database required — everything runs on MemPalace Cloud's servers.

## Verification

After installing, ask Claude: *"What do you know about my preferences?"*

Claude should call `mempalace_search` or `mempalace_kg_query` before answering. If it doesn't, restart Claude Code and try again.

## Troubleshooting

**Claude says "I don't have memory tools"**
- Run `claude mcp list` — you should see `mempalace-cloud` with status `connected`
- If not listed, reinstall: `claude plugin add github:cschnatz/mempalace-cloud-plugin`

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
