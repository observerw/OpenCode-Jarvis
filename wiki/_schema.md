# Wiki Schema & Index

This file is the wiki's "single entry point" for future agents.

- Read this first to understand note conventions and what information exists.
- Use the registries to jump directly to the right note.
- This file stores retrieval metadata only (no secrets / sensitive content).

## Wiki Contract

- **Layout**: `wiki/` is flat; the only subdirectory allowed is `wiki/assets/`.
- **Links**: use standard relative Markdown links (e.g. `./some-note.md`).
- **Filenames**: kebab-case; keep stable names; rename only when meaning changes.

### Note Frontmatter (YAML)

Notes SHOULD have YAML frontmatter. Use these fields when possible:

- `title` (string, required)
- `summary` (string, 1-2 lines, required for important/canonical notes)
- `tags` (string[], optional)
- `aliases` (string[], optional)
- `entities` (string[], optional; people/orgs/projects/systems)
- `updated_at` (YYYY-MM-DD, optional)

Example:

```yaml
---
title: Example Note
summary: One or two lines describing what this note is for.
tags: [project-x, onboarding]
aliases: ["X Overview"]
entities: [Project X, Team A]
updated_at: 2026-02-16
---
```
