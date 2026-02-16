---
name: today
description: Raw task data for today's briefing
agent: jarvis
---

now_local:
!`date "+%Y-%m-%d %H:%M:%S %z"`

tasks_active:
!`sqlite3 -json db/db.sqlite "SELECT id, parent_id, title, status, scheduled_start, scheduled_end, actual_start, actual_end, created_at, updated_at, completed_at FROM tasks WHERE status IN ('pending','in_progress') ORDER BY (status = 'in_progress') DESC, (scheduled_end IS NULL) ASC, scheduled_end ASC, (scheduled_start IS NULL) ASC, scheduled_start ASC, created_at DESC LIMIT 200;"`

task_dependencies_active:
!`sqlite3 -json db/db.sqlite "SELECT task_id, depends_on_id FROM task_dependencies WHERE task_id IN (SELECT id FROM tasks WHERE status IN ('pending','in_progress')) ORDER BY task_id ASC, depends_on_id ASC;"`

task_tags_active:
!`sqlite3 -json db/db.sqlite "SELECT task_id, tag FROM task_tags WHERE task_id IN (SELECT id FROM tasks WHERE status IN ('pending','in_progress')) ORDER BY task_id ASC, tag ASC;"`

tasks_completed_today:
!`sqlite3 -json db/db.sqlite "SELECT id, title, completed_at FROM tasks WHERE status = 'completed' AND completed_at IS NOT NULL AND date(datetime(completed_at,'localtime')) = date('now','localtime') ORDER BY completed_at DESC LIMIT 50;"`

instructions:

- Based on the data above, report what should be done today and propose a simple time-block plan.
