---
description: Today's Task Overview and Intelligent Planning
agent: jarvis
---

## Today's Tasks

!`just today`

## Overdue Tasks

!`just overdue`

## Long-term Tasks (Project Milestones)

!`just milestones`

## User Input

$ARGUMENTS

---

Based on the provided data and user input, complete the following:

1. Present today's tasks in a table (time, title, notes). Highlight overdue tasks in red. Show long-term tasks separately to remind the user.
2. If the user has a specific question (e.g., "Am I free this afternoon?"), answer directly.
3. If the user requests an operation (e.g., "Postpone"), execute the corresponding `just` command.
4. If there is no specific question, provide suggestions for today's schedule.

Examples of user input: "Help me plan my day", "Am I free this afternoon?", "Push all overdue tasks to tomorrow".

---

**Tool Tips**:
- Run `just --list` or `just help` to see all available operations.
- For unconventional queries, you can write manual `jq` (refer to `just schema`), but prioritize `just` commands.
