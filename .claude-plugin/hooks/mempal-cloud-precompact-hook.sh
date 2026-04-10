#!/bin/bash
# MemPalace Cloud PreCompact Hook — save everything before context compaction
# Always blocks — compaction means losing detailed context
echo '{"decision":"block","reason":"COMPACTION IMMINENT. Save ALL topics, decisions, quotes, code, and important context from this session to MemPalace Cloud. Use mempalace_diary_write for narrative summaries, mempalace_kg_add for atomic facts, and mempalace_add_drawer for larger knowledge chunks. Be thorough — after compaction, detailed context will be lost. If MCP token is expired, tell the user to re-authenticate with /mcp. Save everything, then allow compaction to proceed."}'
