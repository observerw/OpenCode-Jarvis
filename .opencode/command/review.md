---
description: Periodic Review and Progress Analysis
agent: jarvis
---

## System Context

Current Time: !`date "+%Y-%m-%d %H:%M %A"`

Check `just` installation:

!`which just`

Check `jq` installation:

!`which jq`

## Recently Completed (Last 7 Days)

!`just recent-done`

## Status Statistics

!`just stats-status`

## Available Operations

!`just help`

## User Input

$ARGUMENTS

---

Based on the provided data and user input, complete the review analysis:

1. Understand the scope the user wants to review (this week, this month, a specific project, or overall).
2. Use `just` commands to get more data if needed:
   - Time range: `just filter-completed <start> <end>`
   - Project progress: `just find-entity <name>` → `just stats-project <id>`
   - Load analysis: `just stats-by-day <start> <end>`
3. Present statistical results in tables or simple charts.
4. Provide 1-2 actionable suggestions for productivity improvement.

Examples of user input:

- "What did I do this week?"
- "What is the completion rate for this month?"
- "How is the Double 11 project progressing?"
- "Have I been overscheduled lately?"

---

**Tool Tips**:

- Run `just --list` or `just help` to see all available operations.
- For unconventional queries, you can write manual `jq` (refer to `just schema`), but prioritize `just` commands.
