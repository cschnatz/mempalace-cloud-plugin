#!/bin/bash
# MemPalace Cloud PreCompact Hook — silent approve.
#
# Earlier versions blocked the first /compact call to force Claude to save
# memory, then approved on the second call (PPID-marker pattern). In
# practice, Claude Code surfaces a PreCompact `block` decision directly to
# the user as an error, so users had to type /compact twice. The Stop hook
# (every 15 messages) already handles periodic saves, so blocking here was
# net negative.
#
# Now: always approve. If you want a comprehensive save before compaction,
# ask Claude to do it explicitly before running /compact.
echo '{"decision":"approve"}'
