# Jarvis Task Management Commands
# Run `just --list` to see all commands
# Run `just help` for detailed usage

data_dir := "data"
archive_dir := data_dir / "archives"
tasks := data_dir / "tasks.json"
entities := data_dir / "entities.json"

# Show JSON schema for Task and Entity
schema:
    @echo "Task: {id, title, content?, status, created_at, due_at?, completed_at?, parent_id?, depends_on[]?, entities[]?, recurrence?, note?}"
    @echo "Entity: {id, type, name, note?}"
    @echo ""
    @echo "status: pending | done | cancelled"
    @echo "type: person | place | project | tag"
    @echo "dates: ISO format (2026-02-07T14:00)"
    @echo "recurrence: <num>d (days) | <num>m (months)"

# Show detailed help for all commands
help:
    @echo "=== Jarvis Task Management ==="
    @echo ""
    @echo "QUERY - Basic:"
    @echo "  just filter-status <status>              Filter by status (pending/done/cancelled)"
    @echo "  just filter-due <start> <end>            Filter by due_at range (ISO format)"
    @echo "  just filter-completed <start> <end>      Filter by completed_at range"
    @echo "  just filter-entity <entity_id>           Filter tasks by entity"
    @echo "  just filter-children <parent_id>         Filter subtasks by parent"
    @echo "  just find-entity <name>                  Find entity by name (fuzzy)"
    @echo "  just find-entity-type <type>             Find entity by type (person/place/project/tag)"
    @echo "  just get-task <id>                       Get single task"
    @echo "  just get-entity <id>                     Get single entity"
    @echo ""
    @echo "QUERY - Common:"
    @echo "  just today                               Today's tasks"
    @echo "  just pending                             All pending tasks"
    @echo "  just overdue                             Overdue tasks"
    @echo "  just upcoming                            Upcoming tasks (next 30 days)"
    @echo "  just milestones                          Project milestones"
    @echo "  just this-week                           This week's tasks"
    @echo "  just recent-done                         Completed in last 7 days"
    @echo ""
    @echo "QUERY - Stats:"
    @echo "  just stats-status                        Count by status"
    @echo "  just stats-by-day <start> <end>          Count by day in range"
    @echo "  just stats-project <entity_id>           Project progress"
    @echo "  just stats-children <parent_id>          Subtasks progress"
    @echo ""
    @echo "QUERY - List:"
    @echo "  just list                                List all tasks (compact)"
    @echo "  just list-entities                       List all entities"
    @echo "  just list-projects                       List all projects"
    @echo ""
    @echo "UPDATE - Basic:"
    @echo "  just add-task <title> [due] [rec]        Create task"
    @echo "  just add-entity <type> <name>            Create entity"
    @echo "  just set-task-field <id> <field> <val>   Update task field"
    @echo "  just clear-task-field <id> <field>       Clear task field (set null)"
    @echo "  just set-entity-field <id> <field> <val> Update entity field"
    @echo "  just append-task-field <id> <field> <v>  Append to array field"
    @echo "  just remove-from-task-field <id> <f> <v> Remove from array field"
    @echo "  just delete-task <id>                    Delete task"
    @echo "  just delete-entity <id>                  Delete entity"
    @echo ""
    @echo "UPDATE - Common:"
    @echo "  just complete-task <id>                  Mark task done"
    @echo "  just cycle-recurring-task <id>           Complete recurring and create next"
    @echo "  just cancel-task <id>                    Cancel task"
    @echo "  just reopen-task <id>                    Reopen task"
    @echo "  just postpone-task <id> <new_due>        Change due date"
    @echo "  just link-entity <task_id> <entity_id>   Link entity to task"
    @echo "  just unlink-entity <task_id> <entity_id> Unlink entity from task"
    @echo "  just add-dependency <task> <dep>         Add dependency"
    @echo "  just set-parent <task_id> <parent_id>    Set parent task"
    @echo "  just set-note <id> <note>                Set note"
    @echo ""
    @echo "SETUP:"
    @echo "  just init                                Initialize data files"

# === QUERY - Basic ===

# Filter by status (pending/done/cancelled)
filter-status status:
    jq --arg s "{{status}}" '[.[] | select(.status == $s)]' {{tasks}}

# Filter by due_at range [start, end)
filter-due start end:
    jq --arg s "{{start}}" --arg e "{{end}}" \
      '[.[] | select(.due_at != null and .due_at >= $s and .due_at < $e)]' {{tasks}}

# Filter by completed_at range [start, end)
filter-completed start end:
    jq --arg s "{{start}}" --arg e "{{end}}" \
      '[.[] | select(.completed_at != null and .completed_at >= $s and .completed_at < $e)]' {{tasks}}

# Filter tasks by entity id
filter-entity entity_id:
    jq --arg e "{{entity_id}}" '[.[] | select(.entities != null and (.entities | index($e)))]' {{tasks}}

# Filter subtasks by parent id
filter-children parent_id:
    jq --arg p "{{parent_id}}" '[.[] | select(.parent_id == $p)]' {{tasks}}

# Find entity by name (case-insensitive fuzzy match)
find-entity name:
    jq --arg n "{{name}}" '[.[] | select(.name | test($n; "i"))]' {{entities}}

# Find entity by type (person/place/project/tag)
find-entity-type type:
    jq --arg t "{{type}}" '[.[] | select(.type == $t)]' {{entities}}

# Get single task by id
get-task id:
    jq --arg id "{{id}}" '.[] | select(.id == $id)' {{tasks}}

# Get single entity by id
get-entity id:
    jq --arg id "{{id}}" '.[] | select(.id == $id)' {{entities}}

# === QUERY - Common ===

# Today's tasks sorted by due_at
today:
    jq --arg s "$(date +%Y-%m-%d)" --arg e "$(date -v+1d +%Y-%m-%d 2>/dev/null || date -d '+1 day' +%Y-%m-%d)" \
      '[.[] | select(.due_at != null and .due_at >= $s and .due_at < $e)] | sort_by(.due_at)' {{tasks}}

# All pending tasks
pending:
    just filter-status pending

# Overdue tasks (pending with due_at in past)
overdue:
    jq --arg now "$(date +%Y-%m-%dT%H:%M)" \
      '[.[] | select(.status == "pending" and .due_at != null and .due_at < $now)]' {{tasks}}

# This week's tasks
this-week:
    #!/usr/bin/env bash
    if [[ "$(uname)" == "Darwin" ]]; then
      start=$(date -v-$(date +%u)d -v+1d +%Y-%m-%d)
      end=$(date -v-$(date +%u)d -v+8d +%Y-%m-%d)
    else
      start=$(date -d "last monday" +%Y-%m-%d)
      end=$(date -d "next monday" +%Y-%m-%d)
    fi
    jq --arg s "$start" --arg e "$end" \
      '[.[] | select(.due_at != null and .due_at >= $s and .due_at < $e)] | sort_by(.due_at)' {{tasks}}

# Upcoming tasks (next 30 days, excluding today)
upcoming:
    #!/usr/bin/env bash
    if [[ "$(uname)" == "Darwin" ]]; then
      start=$(date -v+1d +%Y-%m-%d)
      end=$(date -v+31d +%Y-%m-%d)
    else
      start=$(date -d '+1 day' +%Y-%m-%d)
      end=$(date -d '+31 days' +%Y-%m-%d)
    fi
    jq --arg s "$start" --arg e "$end" \
      '[.[] | select(.status == "pending" and .due_at != null and .due_at >= $s and .due_at < $e)] | sort_by(.due_at)' {{tasks}}

# Milestones (pending tasks linked to projects, sorted by due_at)
milestones:
    #!/usr/bin/env bash
    project_ids=$(jq -r '[.[] | select(.type == "project")] | .[].id' {{entities}})
    jq --argjson pids "$(echo "$project_ids" | jq -R -s 'split("\n") | map(select(length > 0))')" \
      '[.[] | select(.status == "pending" and .entities != null and ([.entities[] | . as $e | $pids | index($e)] | any))] | sort_by(.due_at)' {{tasks}}

# Completed in last 7 days
recent-done:
    #!/usr/bin/env bash
    if [[ "$(uname)" == "Darwin" ]]; then
      start=$(date -v-7d +%Y-%m-%d)
    else
      start=$(date -d '-7 days' +%Y-%m-%d)
    fi
    jq --arg s "$start" \
      '[.[] | select(.status == "done" and .completed_at != null and .completed_at >= $s)]' {{tasks}}

# === QUERY - Stats ===

# Count tasks by day in range
stats-by-day start end:
    jq --arg s "{{start}}" --arg e "{{end}}" '[.[] | select(.due_at != null and .due_at >= $s and .due_at < $e)] | group_by(.due_at[:10]) | map({date: .[0].due_at[:10], count: length}) | sort_by(.date)' {{tasks}}

# Count tasks by status
stats-status:
    jq 'group_by(.status) | map({status: .[0].status, count: length})' {{tasks}}

# Project progress (by entity id)
stats-project entity_id:
    jq --arg p "{{entity_id}}" '[.[] | select(.entities != null and (.entities | index($p)))] | {total: length, done: ([.[] | select(.status == "done")] | length), pending: ([.[] | select(.status == "pending")] | length), cancelled: ([.[] | select(.status == "cancelled")] | length)}' {{tasks}}

# Subtasks progress (by parent id)
stats-children parent_id:
    jq --arg p "{{parent_id}}" '[.[] | select(.parent_id == $p)] | {total: length, done: ([.[] | select(.status == "done")] | length), pending: ([.[] | select(.status == "pending")] | length)}' {{tasks}}

# === QUERY - List ===

# List all tasks (compact: id, title, due_at, status)
list filter=".":
    jq '{{filter}} | .[] | {id, title, due_at, status}' {{tasks}}

# List all entities (compact: id, type, name)
list-entities:
    jq '.[] | {id, type, name}' {{entities}}

# List all projects
list-projects:
    just find-entity-type project

# === UPDATE - Basic ===

# (internal) Generate task id
_gen-task-id:
    @echo "task_$(date +%s)_$(head -c 4 /dev/urandom | xxd -p)"

# (internal) Generate entity id
_gen-entity-id:
    @echo "ent_$(date +%s)_$(head -c 4 /dev/urandom | xxd -p)"

# Create task (returns id)
add-task title due_at="null" recurrence="null":
    #!/usr/bin/env bash
    id=$(just _gen-task-id)
    now=$(date -u +%Y-%m-%dT%H:%M:%S)
    due_val='{{due_at}}'
    rec_val='{{recurrence}}'
    if [[ "$due_val" != "null" ]]; then due_val="\"$due_val\""; fi
    if [[ "$rec_val" != "null" ]]; then rec_val="\"$rec_val\""; fi
    jq --arg id "$id" --arg title "{{title}}" --arg now "$now" --argjson due "$due_val" --argjson rec "$rec_val" \
      '. += [{id: $id, title: $title, status: "pending", created_at: $now, due_at: $due, recurrence: $rec}]' \
      {{tasks}} > {{tasks}}.tmp && mv {{tasks}}.tmp {{tasks}}
    echo "$id"

# Create entity (returns id)
add-entity type name:
    #!/usr/bin/env bash
    id=$(just _gen-entity-id)
    jq --arg id "$id" --arg type "{{type}}" --arg name "{{name}}" \
      '. += [{id: $id, type: $type, name: $name}]' \
      {{entities}} > {{entities}}.tmp && mv {{entities}}.tmp {{entities}}
    echo "$id"

# Update task field (string value)
set-task-field id field value:
    jq --arg id "{{id}}" --arg field "{{field}}" --arg value "{{value}}" \
      'map(if .id == $id then .[$field] = $value else . end)' \
      {{tasks}} > {{tasks}}.tmp && mv {{tasks}}.tmp {{tasks}}

# Clear task field (set to null)
clear-task-field id field:
    jq --arg id "{{id}}" --arg field "{{field}}" \
      'map(if .id == $id then .[$field] = null else . end)' \
      {{tasks}} > {{tasks}}.tmp && mv {{tasks}}.tmp {{tasks}}

# Update entity field
set-entity-field id field value:
    jq --arg id "{{id}}" --arg field "{{field}}" --arg value "{{value}}" \
      'map(if .id == $id then .[$field] = $value else . end)' \
      {{entities}} > {{entities}}.tmp && mv {{entities}}.tmp {{entities}}

# Append value to task array field (entities, depends_on)
append-task-field id field value:
    jq --arg id "{{id}}" --arg field "{{field}}" --arg value "{{value}}" \
      'map(if .id == $id then .[$field] = ((.[$field] // []) + [$value]) else . end)' \
      {{tasks}} > {{tasks}}.tmp && mv {{tasks}}.tmp {{tasks}}

# Remove value from task array field
remove-from-task-field id field value:
    jq --arg id "{{id}}" --arg field "{{field}}" --arg value "{{value}}" \
      'map(if .id == $id then .[$field] = ([.[$field][] | select(. != $value)]) else . end)' \
      {{tasks}} > {{tasks}}.tmp && mv {{tasks}}.tmp {{tasks}}

# Delete task by id
delete-task id:
    jq --arg id "{{id}}" '[.[] | select(.id != $id)]' \
      {{tasks}} > {{tasks}}.tmp && mv {{tasks}}.tmp {{tasks}}

# Delete entity by id
delete-entity id:
    jq --arg id "{{id}}" '[.[] | select(.id != $id)]' \
      {{entities}} > {{entities}}.tmp && mv {{entities}}.tmp {{entities}}

# === UPDATE - Common ===

# Mark task as done (sets status + completed_at, archives to date-based file)
complete-task id:
    #!/usr/bin/env bash
    now=$(date -u +%Y-%m-%dT%H:%M:%S)
    # 1. Update status in tasks.json
    jq --arg id "{{id}}" --arg now "$now" \
      'map(if .id == $id or .parent_id == $id then .status = "done" | .completed_at = $now else . end)' \
      {{tasks}} > {{tasks}}.tmp || exit 1
    
    # 2. Extract tasks to archive (all tasks with status "done")
    done_tasks=$(jq -c '[.[] | select(.status == "done")]' {{tasks}}.tmp)
    
    if [ "$done_tasks" != "[]" ]; then
        # 3. Archive each task by its completion date
        # Use jq to output lines of "YYYY-MM-DD <json_object>"
        echo "$done_tasks" | jq -r '.[] | "\(.completed_at[:10]) \(. | @json)"' | while read -r date task_json; do
            archive_file="{{archive_dir}}/$date.json"
            [ -f "$archive_file" ] || echo '[]' > "$archive_file"
            jq --argjson t "$task_json" '. += [$t] | unique_by(.id)' "$archive_file" > "$archive_file.tmp" && mv "$archive_file.tmp" "$archive_file"
        done
        
        # 4. Remove archived tasks from main tasks.json
        jq '[.[] | select(.status != "done")]' {{tasks}}.tmp > {{tasks}}.final && mv {{tasks}}.final {{tasks}}
        rm {{tasks}}.tmp
    else
        mv {{tasks}}.tmp {{tasks}}
    fi

# Complete current recurring task and create next instance
cycle-recurring-task id:
    #!/usr/bin/env bash
    task_json=$(jq --arg id "{{id}}" '.[] | select(.id == $id)' {{tasks}})
    if [ -z "$task_json" ]; then echo "Task not found"; exit 1; fi
    
    # 1. Complete current task
    just complete-task "{{id}}"
    
    # 2. Check for recurrence
    recurrence=$(echo "$task_json" | jq -r '.recurrence // empty')
    if [ -z "$recurrence" ]; then
        echo "Task completed (no recurrence)."
        exit 0
    fi
    
    # 3. Calculate next due date
    due_at=$(echo "$task_json" | jq -r '.due_at // empty')
    if [ -z "$due_at" ]; then
        due_at=$(date -u +%Y-%m-%dT%H:%M:%S)
    fi
    
    num=${recurrence%[dm]}
    unit=${recurrence#$num}
    
    if [[ "$(uname)" == "Darwin" ]]; then
        # Try full ISO format first, fallback to YYYY-MM-DD
        if [[ "$unit" == "d" ]]; then
            next_due=$(date -v+"$num"d -jf "%Y-%m-%dT%H:%M:%S" "$due_at" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null || date -v+"$num"d -jf "%Y-%m-%d" "$due_at" "+%Y-%m-%dT%H:%M:%S")
        elif [[ "$unit" == "m" ]]; then
            next_due=$(date -v+"$num"m -jf "%Y-%m-%dT%H:%M:%S" "$due_at" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null || date -v+"$num"m -jf "%Y-%m-%d" "$due_at" "+%Y-%m-%dT%H:%M:%S")
        fi
    else
        if [[ "$unit" == "d" ]]; then
            next_due=$(date -d "$due_at + $num days" "+%Y-%m-%dT%H:%M:%S")
        elif [[ "$unit" == "m" ]]; then
            next_due=$(date -d "$due_at + $num months" "+%Y-%m-%dT%H:%M:%S")
        fi
    fi
    
    # 4. Create new task instance
    new_id=$(just _gen-task-id)
    now=$(date -u +%Y-%m-%dT%H:%M:%S)
    
    title=$(echo "$task_json" | jq -r '.title')
    content=$(echo "$task_json" | jq '.content')
    entities=$(echo "$task_json" | jq '.entities // []')
    note=$(echo "$task_json" | jq '.note')
    parent_id=$(echo "$task_json" | jq '.parent_id')
    
    jq --arg id "$new_id" \
       --arg title "$title" \
       --argjson content "$content" \
       --arg now "$now" \
       --arg due "$next_due" \
       --arg rec "$recurrence" \
       --argjson ent "$entities" \
       --argjson note "$note" \
       --argjson pid "$parent_id" \
       '. += [{id: $id, title: $title, content: $content, status: "pending", created_at: $now, due_at: $due, recurrence: $rec, entities: $ent, note: $note, parent_id: $pid}]' \
       {{tasks}} > {{tasks}}.tmp && mv {{tasks}}.tmp {{tasks}}
    
    echo "Created next instance: $new_id with due_at $next_due"

# Cancel task
cancel-task id:
    just set-task-field "{{id}}" status cancelled

# Reopen task (pending + clear completed_at)
reopen-task id:
    jq --arg id "{{id}}" \
      'map(if .id == $id then .status = "pending" | .completed_at = null else . end)' \
      {{tasks}} > {{tasks}}.tmp && mv {{tasks}}.tmp {{tasks}}

# Postpone task (change due_at)
postpone-task id new_due:
    just set-task-field "{{id}}" due_at "{{new_due}}"

# Link entity to task
link-entity task_id entity_id:
    just append-task-field "{{task_id}}" entities "{{entity_id}}"

# Unlink entity from task
unlink-entity task_id entity_id:
    just remove-from-task-field "{{task_id}}" entities "{{entity_id}}"

# Add task dependency (task depends on another)
add-dependency task_id depends_on_id:
    just append-task-field "{{task_id}}" depends_on "{{depends_on_id}}"

# Set parent task (make subtask)
set-parent task_id parent_id:
    just set-task-field "{{task_id}}" parent_id "{{parent_id}}"

# Set task note
set-note id note:
    just set-task-field "{{id}}" note "{{note}}"

# === SETUP ===

# Initialize data files (if not exist)
init:
    #!/usr/bin/env bash
    mkdir -p {{data_dir}}
    mkdir -p {{archive_dir}}
    [ -f {{tasks}} ] || echo '[]' > {{tasks}}
    [ -f {{entities}} ] || echo '[]' > {{entities}}
    echo "Initialized {{data_dir}}/"
