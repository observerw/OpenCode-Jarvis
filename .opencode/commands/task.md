---
name: task
description: Create and manage tasks.
agent: jarvis
---

## Database Schema

!`cat db/schema/task.ts`

## Info

- Current date: !`date`
- A free uuid you can use: !`uuidgen`

---

## Workflow

- Understand user intent.
- Extract required user info first: task title; fields to set; optional tags/entities/dependencies.
- Apply changes with the fewest DB statements (transaction only if touching multiple tables).
- Always re-query and show results.

## Rules

- Any update MUST set `updatedAt = datetime('now')`.
- If status -> `completed`/`cancelled`: MUST set `completedAt=now` (set `actualEnd` if empty).
- If status -> `pending`/`in_progress`: `completedAt` MUST be NULL.
- Do not delete unless user explicitly asks; prefer `cancelled`.
- Prevent dependency cycles.

---

## User Request

$ARGUMENTS
