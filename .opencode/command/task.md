---
description: Task Management - Describe in natural language
agent: jarvis
---

## System Context

Current Time: !`date "+%Y-%m-%d %H:%M %A"`

Check `just` installation:

!`which just`

Check `jq` installation:

!`which jq`

## Data Schema

!`just schema`

## Available Operations

!`just help`

## Requirements

Understand the user's intent from their input and perform the corresponding operations:

1. **Create Task**: Extract title, time, and related people/places. Use `just` commands to create tasks and entities and link them.
2. **Query Task**: Select the appropriate `just` query command; use `jq` for combined filtering if necessary.
3. **Modify Task**: Locate the target task and use `just` commands to update status, time, or notes.
4. **Analyze Stats**: Use the `stats` series of commands to retrieve data and provide interpretations.

Briefly confirm results after the operation is complete.

Examples of user input:

- "Meeting with Manager Li at 3 PM tomorrow via Tencent Meeting"
- "Remind me to buy toothpaste"
- "How much of Project A is left?"
- "Cancel that report task"

---

**Tool Tips**:

- Run `just --list` or `just help` to see all available operations.
- For unconventional queries, you can write manual `jq` (refer to the schema in the system prompt), but prioritize `just` commands.

---

## User Input

$ARGUMENTS
