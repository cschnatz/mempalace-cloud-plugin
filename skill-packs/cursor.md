# MemPalace Cloud — Cursor Setup

## Setup

### 1. Add the MCP server

Open **Cursor Settings → MCP Servers → Add new** and paste:

```json
{
  "mcpServers": {
    "mempalace-cloud": {
      "url": "https://api.mempalace.cloud/mcp"
    }
  }
}
```

Cursor should show a green dot next to `mempalace-cloud` once connected.
On first connection, a browser opens for OAuth login.

### 2. Add the memory protocol to User Rules

Cursor doesn't support plugins the way Claude Code does, so the memory
protocol has to be pasted into Rules once.

The full, up-to-date instruction block is hosted at:

**https://www.mempalace.cloud/skill-packs/cursor-rules.md**

Copy its content and paste it into:

**Cursor Settings → Rules → User Rules**

(Use User Rules, not project-level `.cursorrules` — User Rules get the
broadest coverage across Compose, Chat, and Inline.)

The hosted version is kept in sync with the plugin (currently v1.3.0) and
includes Discovery First, Palace Structure, the Save Decision Flow with
Creation Gate, and Anti-patterns.

## Verification

Open the Cursor chat panel and ask:

> "What do you know about my preferences?"

Cursor should call `mempalace_list_wings` followed by `mempalace_search`
before answering.

## Updates

When the plugin version bumps (e.g., 1.2.0 → 1.3.0), re-copy the hosted
block into your User Rules to stay current. There is no automatic update
path for pasted rules.
