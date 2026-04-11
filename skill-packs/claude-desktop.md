# MemPalace Cloud — Claude Desktop Setup

## Setup

### 1. Connect the MCP server

Run this in your terminal:

```bash
claude mcp add mempalace-cloud --transport http https://api.mempalace.cloud/mcp -s user
```

This opens a browser window for OAuth login. After login, quit and restart
Claude Desktop.

### 2. Add the memory protocol to Custom Instructions

Claude Desktop doesn't support plugins, so the memory protocol has to be
pasted into Custom Instructions once per project (or globally in Settings).

The full, up-to-date instruction block is hosted at:

**https://www.mempalace.cloud/skill-packs/claude-desktop-instructions.md**

Copy its content and paste it into:

- **Project:** Open a Project → Project Settings → Custom Instructions
- **Global:** Settings → Profile → What personal preferences should Claude consider in responses?

The hosted version is kept in sync with the plugin (currently v1.2.0) and
includes Discovery First, Palace Structure, the Save Decision Flow with
Creation Gate, and Anti-patterns.

## Verification

Start a new conversation in the project and ask:

> "What do you know about my preferences?"

Claude should call `mempalace_list_wings` followed by `mempalace_search`
before answering.

## Updates

When the plugin version bumps (e.g., 1.2.0 → 1.3.0), re-copy the hosted
block into your Custom Instructions to stay current. There is no automatic
update path for pasted instructions.
