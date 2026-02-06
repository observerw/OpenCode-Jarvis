---
name: task-data
description: Used to manage and query Jarvis system task data, supporting CRUD and various filtering conditions.
---

# Task Data Skill

Use `just` commands to operate on task and entity data.

## Quick Start

```bash
# View all commands
just --list

# View detailed help
just help

# View data schema
just schema
```

## Data Structure

```
Task: {id, title, content?, status, created_at, due_at?, completed_at?, parent_id?, depends_on[]?, entities[]?, note?}
Entity: {id, type, name, note?}

status: pending | done | cancelled
type: person | place | project | tag
dates: ISO format (2026-02-07T14:00)
```

- `?` indicates optional fields
- `[]` indicates an array

## Common Queries

```bash
just today              # Today's tasks
just pending            # All pending tasks
just overdue            # Overdue tasks
just this-week          # Tasks for this week
just recent-done        # Tasks completed in the last 7 days
```

## Common Updates

```bash
just add-task "Task Title" "2026-02-07T14:00"  # Create task
just complete-task <id>                       # Complete task
just cancel-task <id>                         # Cancel task
just postpone-task <id> "2026-02-10T14:00"   # Postpone task
```

## Entity Management

```bash
just add-entity person "Teacher Wang"       # Create person
just add-entity project "Double 11 Event"  # Create project
just link-entity <task_id> <entity_id>     # Link task to entity
just find-entity "Wang"                    # Fuzzy search for entity
```

## Combined Queries

All commands output JSON, which can be combined via pipes:

```bash
# Pending tasks for this week
just filter-due "2026-02-03" "2026-02-10" | jq '[.[] | select(.status == "pending")]'

# Pending tasks for a specific project
just filter-entity ent_proj_123 | jq '[.[] | select(.status == "pending")]'

# Find project by name -> Query tasks
entity_id=$(just find-entity "Double 11" | jq -r '.[0].id')
just filter-entity "$entity_id"
```

## Custom JQ Queries

When built-in commands are insufficient, use `jq` directly:

```bash
# View data schema
just schema

# Query directly
jq '[.[] | select(.title | test("report"; "i"))]' data/tasks.json
jq '[.[] | select(.note != null and (.note | test("urgent")))]' data/tasks.json
```

## Statistical Analysis

```bash
just stats-status                    # Status distribution
just stats-by-day "2026-02-01" "2026-02-28"  # Daily statistics
just stats-project <entity_id>       # Project progress
just stats-children <parent_id>      # Subtask progress
```
