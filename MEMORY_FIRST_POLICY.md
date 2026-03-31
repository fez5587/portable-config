# Memory-First Policy (OpenViking)

Use this policy text in any agent `systemPrompt` where you want lower token usage:

1. For non-trivial tasks, call `openviking_search` first with `top_k` 3-5.
2. If relevant matches exist, answer from retrieved evidence instead of broad context expansion.
3. If needed, call `openviking_read` only on the top hits.
4. Keep injected context compact (summary + small excerpts), avoid large raw dumps.
5. After producing reusable output, call `openviking_upsert` with concise notes.
6. If OpenViking is unavailable, continue using normal model fallbacks without blocking.
