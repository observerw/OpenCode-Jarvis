---
name: organize
description: Reorganize and normalize wiki/ notes for easier retrieval
agent: jarvis
---

## Current Wiki Schema

!`cat wiki/_schema.md`

---

## Workflow

- Read the user's instructions and identify the concrete changes requested.
- Review the current state of `wiki/` (Markdown notes) and `wiki/assets/` (attachments).
- Propose a concrete change list (files to create/update/rename/merge and link updates).
- Apply the changes in `wiki/` while keeping notes as standard Markdown with valid YAML frontmatter.
- Validate that `wiki/` remains flat (no subdirectories besides `wiki/assets/`) and links are standard relative Markdown links.
- Update `wiki/_schema.md` (see "Schema Update" section) to record the minimum necessary metadata and indexes for retrieval.
- Report what changed (created/updated/renamed) and anything that needs user confirmation.

## Schema Update

`wiki/_schema.md` is the wiki's single entry point for future retrieval. After each organize run, make sure it contains:

- A stable "Wiki Contract" (file layout + note frontmatter requirements).
- Auto-updated indexes so another agent can answer: "what notes exist, what are they about, and which note should I read?"
- A short, append-only "Organize Log" entry describing what changed.

Minimum required updates per run:

- Ensure `wiki/_schema.md` exists and follows the section markers in the file.
- Update the indexes at least for notes touched in this run (created/updated/renamed/merged). Prefer regenerating the full registries when the wiki is small; otherwise do an incremental update.
- Record one log entry with:
  - Date (ISO-8601), brief summary, and links to changed notes.
  - Renames in the format: `old -> new`.

Index fields to capture (best-effort, keep concise):

- Note file, `title`, `summary` (1-2 lines), `tags`, `aliases`.
- Key entities (people/orgs/projects/systems) mentioned in the note.

Safety for schema updates:

- Do not copy sensitive content into `_schema.md` (keys, tokens, secrets, private data). Store only retrieval metadata.
- Keep `_schema.md` readable and not overly long; prefer concise summaries and stable naming.

## Safety

- Never delete notes or assets without explicit user confirmation.
- Never delete `wiki/_schema.md`.

## Response

- One-sentence description of what was reorganized.
- List key artifacts:
  - Created: `wiki/<file>.md`
  - Updated: `wiki/<file>.md`
  - Renamed: `wiki/<old>.md` -> `wiki/<new>.md`
- Mention schema updates: `wiki/_schema.md` (updated indexes + log entry).
