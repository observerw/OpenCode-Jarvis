# Jarvis

Jarvis is a personal data assistant: it helps you capture, organize, and retrieve daily information across two sources (structured data + notes), and turns it into actionable briefs, lists, and summaries.

## What it can do

- Turn scattered inputs into a searchable personal knowledge base
- Produce structured views (filters, lists, lightweight tables) when you need clarity fast
- Manage notes and attachments (create/update Markdown notes, keep links consistent)
- Help you stay on track with task tracking and a daily plan

## What you are managing

- Structured data: stored in a local SQLite database (good for tasks, statuses, tags, timelines)
- Unstructured data: Markdown notes in `wiki/` plus attachments in `wiki/assets/`

## Common commands

- `/today`: generate a daily briefing and a simple time-block plan from active/completed tasks
- `/task ...`: create/update/complete tasks so work stays trackable
- `/inbox`: archive files under `inbox/` into `wiki/` (and `wiki/assets/` when needed)
- `/organize`: normalize and reorganize `wiki/` for more reliable retrieval
