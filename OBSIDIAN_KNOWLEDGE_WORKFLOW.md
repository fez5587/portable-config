# Obsidian Knowledge Workflow (Recommended)

## Decision

Use **Obsidian Canvas** as the primary workspace, then add mind map views only for summary snapshots.

Reason:
- Canvas handles mixed artifacts better (notes, links, files, tasks, prompts).
- Your autoresearch flow needs iterative evidence tracking, not only tree structures.
- Canvas works well with role-based agent outputs from OpenCode.

## Suggested structure

Create a vault folder:

- `Research/Inbox/`
- `Research/Sources/`
- `Research/Summaries/`
- `Research/Canvas/`

Create one canvas per initiative:

- `Research/Canvas/<topic>.canvas`

## Autoresearch loop

1. Run OpenCode agent/research tasks.
2. Save output markdown into `Research/Sources/`.
3. Generate a short synthesis note in `Research/Summaries/`.
4. Place both on Canvas:
   - source nodes
   - synthesis nodes
   - decision nodes
5. Link unresolved questions back to next OpenCode task.

## Optional mind map usage

Use mind maps only for:
- executive brief snapshots
- taxonomy views
- fast planning overviews

Do not use mind maps as the system of record for evidence and citations.
