---
name: schedule-manager
description: Manages daily schedules, providing intelligent scheduling suggestions and time allocation logic.
---

# Schedule Manager Skill

Schedule management is implemented via `just` commands and the `due_at` field of tasks.

## Schedule Queries

```bash
just today       # Today's tasks (sorted by time)
just this-week   # Tasks for this week
just overdue     # Overdue tasks
```

## Time Range Queries

```bash
# Specific date
just filter-due "2026-02-07" "2026-02-08"

# Specific time period
just filter-due "2026-02-07T09:00" "2026-02-07T12:00"
```

## Free Time Check

```bash
# Check if there are appointments tomorrow afternoon
just filter-due "2026-02-08T12:00" "2026-02-08T18:00" | jq 'length'
# Output 0 means free
```

## Load Analysis

```bash
# Number of tasks per day this week
just stats-by-day "2026-02-03" "2026-02-10"

# Example output:
# [{"date": "2026-02-03", "count": 3}, {"date": "2026-02-04", "count": 5}, ...]
```

## Intelligent Scheduling Suggestions

The agent should follow this logic:

1. **Collect Context**:
   ```bash
   just overdue     # Overdue tasks (highest priority)
   just today       # Today's schedule
   just pending     # All pending tasks
   ```

2. **Analyze Note Field**:
   - Prioritize tasks containing "urgent".
   - Identify time estimates (e.g., "approx. 2 hours").

3. **Suggestion Strategy**:
   - Overdue tasks must be handled first.
   - Schedule important tasks in the morning.
   - Handle short tasks during fragmented time.

## Task Scheduling

```bash
# Create task with time
just add-task "Meeting" "2026-02-07T14:00"

# Postpone task
just postpone-task <id> "2026-02-08T10:00"

# Add note (time estimation, etc.)
just set-note <id> "Estimated 2 hours, requires quiet environment"
```

## Project Progress

```bash
# View all task progress under a project
just stats-project <project_entity_id>

# View subtask progress
just stats-children <parent_task_id>
```
