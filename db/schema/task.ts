import { relations, sql } from "drizzle-orm";
import {
  type AnySQLiteColumn,
  check,
  index,
  primaryKey,
  sqliteTable,
  text,
} from "drizzle-orm/sqlite-core";

/**
 * Task system schema.
 *
 * - `tasks`: unit of work; status + timestamps + hierarchy + scheduling.
 * - `entities`: normalized "things" tasks refer to (person/place/org/project/etc).
 * - `task_tags`: fast, lightweight tags for filtering.
 * - `task_entities`: links tasks <-> entities (many-to-many).
 * - `task_dependencies`: links tasks <-> prerequisite tasks (directed edges).
 *
 * Agent guidance
 * - Always set `updatedAt` on any update: `updatedAt: sql\`(datetime('now'))\``.
 * - Use `completedAt` as the single source of truth for completion time.
 * - Prevent cycles in `task_dependencies` at the application layer (DB only prevents self-edge).
 *
 * Common query patterns live next to each table definition below.
 */

type JsonStringArray = string[];

export const TaskStatusValues = [
  "pending",
  "in_progress",
  "completed",
  "cancelled",
] as const;

export type TaskStatus = (typeof TaskStatusValues)[number];

export const SuggestedEntityTypes = [
  "person",
  "place",
  "organization",
  "project",
] as const;

export type EntityType = (typeof SuggestedEntityTypes)[number] | (string & {});

/**
 * `entities`: canonical references used by tasks.
 *
 * - `name` and `type` are indexed; prefer name/type queries for fast paths.
 * - `aliases` is a JSON array (SQLite JSON1). Alias lookups are flexible but not indexed.
 *
 * Typical operations (SQL; SQLite)
 *
 *   -- Upsert pattern (if you treat `id` as stable external key)
 *   INSERT INTO entities (id, name, type, aliases, note, created_at, updated_at)
 *   VALUES (?, ?, ?, json(?), ?, datetime('now'), datetime('now'));
 *
 *   -- Name search (indexed)
 *   SELECT * FROM entities
 *   WHERE name LIKE ?
 *   ORDER BY name ASC;
 *
 *   -- Name-or-alias search (alias requires json_each)
 *   SELECT * FROM entities e
 *   WHERE e.name LIKE ?
 *      OR EXISTS (
 *        SELECT 1
 *        FROM json_each(e.aliases)
 *        WHERE json_each.value LIKE ?
 *      )
 *   ORDER BY e.name ASC;
 */
export const entities = sqliteTable(
  "entities",
  {
    id: text("id").primaryKey(),
    name: text("name").notNull(),
    type: text("type").notNull(),
    aliases: text("aliases", { mode: "json" }).$type<JsonStringArray>(),
    note: text("note"),
    createdAt: text("created_at").notNull().default(sql`(datetime('now'))`),
    updatedAt: text("updated_at").notNull().default(sql`(datetime('now'))`),
  },
  (t) => [
    index("entities_name_idx").on(t.name),
    index("entities_type_idx").on(t.type),
    check("entities_id_not_blank_check", sql`length(trim(${t.id})) > 0`),
    check("entities_name_not_blank_check", sql`length(trim(${t.name})) > 0`),
    check("entities_type_not_blank_check", sql`length(trim(${t.type})) > 0`),
    check(
      "entities_aliases_json_array_check",
      sql`${t.aliases} is null or (json_valid(${t.aliases}) and json_type(${t.aliases}) = 'array')`,
    ),
    check("entities_updated_at_check", sql`${t.updatedAt} >= ${t.createdAt}`),
  ],
);

/**
 * `tasks`: the canonical unit of work.
 *
 * Status + timestamps (recommended lifecycle)
 * - create: status=pending, set createdAt/updatedAt.
 * - start: status=in_progress, set actualStart, bump updatedAt.
 * - complete/cancel: set status, MUST set completedAt, optionally set actualEnd, bump updatedAt.
 *
 * Hierarchy
 * - Use `parentId` to build a tree (project -> epic -> task -> subtask).
 * - Do NOT encode cross-links with `parentId`; use tags/entities/dependencies instead.
 *
 * Scheduling vs actual
 * - `scheduledStart/End`: planned window.
 * - `actualStart/End`: execution window.
 *
 * Typical operations (SQL; SQLite)
 *
 *   -- Create
 *   INSERT INTO tasks (
 *     id, title, description, status, parent_id,
 *     scheduled_start, scheduled_end,
 *     actual_start, actual_end,
 *     note,
 *     created_at, updated_at, completed_at
 *   ) VALUES (
 *     ?, ?, ?, 'pending', NULL,
 *     NULL, NULL,
 *     NULL, NULL,
 *     NULL,
 *     datetime('now'), datetime('now'), NULL
 *   );
 *
 *   -- Start (guarded transition)
 *   UPDATE tasks
 *   SET status = 'in_progress',
 *       actual_start = COALESCE(actual_start, datetime('now')),
 *       updated_at = datetime('now')
 *   WHERE id = ?
 *     AND status = 'pending'
 *     AND completed_at IS NULL;
 *
 *   -- Complete (MUST set completed_at per DB check)
 *   UPDATE tasks
 *   SET status = 'completed',
 *       completed_at = datetime('now'),
 *       actual_end = COALESCE(actual_end, datetime('now')),
 *       updated_at = datetime('now')
 *   WHERE id = ?
 *     AND status IN ('pending', 'in_progress')
 *     AND completed_at IS NULL;
 *
 *   -- Cancel (same invariant: completed_at must be set)
 *   UPDATE tasks
 *   SET status = 'cancelled',
 *       completed_at = datetime('now'),
 *       actual_end = COALESCE(actual_end, datetime('now')),
 *       updated_at = datetime('now')
 *   WHERE id = ?
 *     AND status IN ('pending', 'in_progress')
 *     AND completed_at IS NULL;
 *
 *   -- Active queue (scheduled first; NULLs last)
 *   SELECT * FROM tasks
 *   WHERE status IN ('pending', 'in_progress')
 *   ORDER BY (scheduled_start IS NULL) ASC, scheduled_start ASC, created_at DESC;
 *
 *   -- Children of a node (hierarchy)
 *   SELECT * FROM tasks
 *   WHERE parent_id = ?
 *   ORDER BY (scheduled_start IS NULL) ASC, scheduled_start ASC, created_at DESC;
 */
export const tasks = sqliteTable(
  "tasks",
  {
    id: text("id").primaryKey(),
    title: text("title").notNull(),
    description: text("description"),
    status: text("status", { enum: TaskStatusValues }).notNull(),
    parentId: text("parent_id").references((): AnySQLiteColumn => tasks.id, {
      onDelete: "set null",
      onUpdate: "cascade",
    }),
    scheduledStart: text("scheduled_start"),
    scheduledEnd: text("scheduled_end"),
    actualStart: text("actual_start"),
    actualEnd: text("actual_end"),
    note: text("note"),
    createdAt: text("created_at").notNull().default(sql`(datetime('now'))`),
    updatedAt: text("updated_at").notNull().default(sql`(datetime('now'))`),
    completedAt: text("completed_at"),
  },
  (t) => [
    index("tasks_parent_id_idx").on(t.parentId),
    index("tasks_status_idx").on(t.status),
    index("tasks_completed_at_idx").on(t.completedAt),
    check("tasks_id_not_blank_check", sql`length(trim(${t.id})) > 0`),
    check("tasks_title_not_blank_check", sql`length(trim(${t.title})) > 0`),
    check(
      "tasks_status_check",
      sql`${t.status} in ('pending', 'in_progress', 'completed', 'cancelled')`,
    ),
    check("tasks_updated_at_check", sql`${t.updatedAt} >= ${t.createdAt}`),
    check(
      "tasks_completed_at_after_created_check",
      sql`${t.completedAt} is null or ${t.completedAt} >= ${t.createdAt}`,
    ),
    check(
      "tasks_completion_state_check",
      sql`(
        (${t.status} in ('completed', 'cancelled') and ${t.completedAt} is not null) or
        (${t.status} in ('pending', 'in_progress') and ${t.completedAt} is null)
      )`,
    ),
    check(
      "tasks_parent_self_check",
      sql`${t.parentId} is null or ${t.parentId} <> ${t.id}`,
    ),
    check(
      "tasks_scheduled_window_check",
      sql`${t.scheduledStart} is null or ${t.scheduledEnd} is null or ${t.scheduledStart} < ${t.scheduledEnd}`,
    ),
    check(
      "tasks_actual_window_check",
      sql`${t.actualStart} is null or ${t.actualEnd} is null or ${t.actualStart} < ${t.actualEnd}`,
    ),
  ],
);

/**
 * `task_dependencies`: directed edges between tasks.
 *
 * Semantics
 * - Row means: `taskId` depends on `dependsOnId` (prerequisite).
 * - DB prevents self-dependency, but NOT dependency cycles.
 *   Agents/app MUST prevent cycles when inserting edges.
 *
 * Typical operations (SQL; SQLite)
 *
 *   -- Add dependency (taskId depends on dependsOnId)
 *   INSERT INTO task_dependencies (task_id, depends_on_id)
 *   VALUES (?, ?);
 *
 *   -- Blocked tasks: has at least one prerequisite not completed
 *   SELECT DISTINCT t.*
 *   FROM tasks t
 *   JOIN task_dependencies d ON d.task_id = t.id
 *   JOIN tasks p ON p.id = d.depends_on_id
 *   WHERE t.status IN ('pending', 'in_progress')
 *     AND p.status <> 'completed';
 *
 *   -- Ready tasks: no unmet prerequisites
 *   SELECT t.*
 *   FROM tasks t
 *   WHERE t.status IN ('pending', 'in_progress')
 *     AND NOT EXISTS (
 *       SELECT 1
 *       FROM task_dependencies d
 *       JOIN tasks p ON p.id = d.depends_on_id
 *       WHERE d.task_id = t.id
 *         AND p.status <> 'completed'
 *     )
 *   ORDER BY (t.scheduled_start IS NULL) ASC, t.scheduled_start ASC, t.created_at DESC;
 */
export const taskDependencies = sqliteTable(
  "task_dependencies",
  {
    taskId: text("task_id")
      .notNull()
      .references(() => tasks.id, { onDelete: "cascade", onUpdate: "cascade" }),
    dependsOnId: text("depends_on_id")
      .notNull()
      .references(() => tasks.id, { onDelete: "cascade", onUpdate: "cascade" }),
  },
  (t) => [
    primaryKey({ columns: [t.taskId, t.dependsOnId] }),
    index("task_dependencies_depends_on_id_idx").on(t.dependsOnId),
    check(
      "task_dependencies_not_self_check",
      sql`${t.taskId} <> ${t.dependsOnId}`,
    ),
  ],
);

/**
 * `task_entities`: link table between tasks and entities.
 *
 * Why it matters
 * - Enables: "show me all tasks for project X" / "all tasks involving person Y".
 *
 * Typical operations (SQL; SQLite)
 *
 *   -- Link an entity to a task
 *   INSERT INTO task_entities (task_id, entity_id)
 *   VALUES (?, ?);
 *
 *   -- Tasks for an entity
 *   SELECT t.*
 *   FROM tasks t
 *   JOIN task_entities te ON te.task_id = t.id
 *   WHERE te.entity_id = ?
 *   ORDER BY t.updated_at DESC;
 */
export const taskEntities = sqliteTable(
  "task_entities",
  {
    taskId: text("task_id")
      .notNull()
      .references(() => tasks.id, { onDelete: "cascade", onUpdate: "cascade" }),
    entityId: text("entity_id")
      .notNull()
      .references(() => entities.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),
  },
  (t) => [
    primaryKey({ columns: [t.taskId, t.entityId] }),
    index("task_entities_entity_id_idx").on(t.entityId),
  ],
);

/**
 * `task_tags`: link table between tasks and tags.
 *
 * Agent guidance
 * - Keep tags stable + predictable (lowercase, short, no spaces) if possible.
 * - Prefer tags for lightweight grouping; use entities for canonical references.
 *
 * Typical operations (SQL; SQLite)
 *
 *   -- Tag a task
 *   INSERT INTO task_tags (task_id, tag)
 *   VALUES (?, ?);
 *
 *   -- Filter by tag
 *   SELECT t.*
 *   FROM tasks t
 *   JOIN task_tags tt ON tt.task_id = t.id
 *   WHERE tt.tag = ?
 *   ORDER BY t.updated_at DESC;
 */
export const taskTags = sqliteTable(
  "task_tags",
  {
    taskId: text("task_id")
      .notNull()
      .references(() => tasks.id, { onDelete: "cascade", onUpdate: "cascade" }),
    tag: text("tag").notNull(),
  },
  (t) => [
    primaryKey({ columns: [t.taskId, t.tag] }),
    index("task_tags_tag_idx").on(t.tag),
    check("task_tags_tag_not_blank_check", sql`length(trim(${t.tag})) > 0`),
  ],
);

export const tasksRelations = relations(tasks, ({ one, many }) => ({
  // Hierarchy: a task can have a parent (and multiple children).
  parent: one(tasks, {
    fields: [tasks.parentId],
    references: [tasks.id],
    relationName: "task_hierarchy",
  }),
  children: many(tasks, { relationName: "task_hierarchy" }),

  // Dependencies: `dependencyLinks` are the edges from this task to its prerequisites.
  // `dependentLinks` are edges from other tasks that require this task.
  dependencyLinks: many(taskDependencies, {
    relationName: "task_dependencies_task",
  }),
  dependentLinks: many(taskDependencies, {
    relationName: "task_dependencies_depends_on",
  }),

  // Cross-references: entities and tags.
  entityLinks: many(taskEntities),
  tagLinks: many(taskTags),
}));

export const entitiesRelations = relations(entities, ({ many }) => ({
  taskLinks: many(taskEntities),
}));

export const taskDependenciesRelations = relations(
  taskDependencies,
  ({ one }) => ({
    task: one(tasks, {
      fields: [taskDependencies.taskId],
      references: [tasks.id],
      relationName: "task_dependencies_task",
    }),
    dependsOn: one(tasks, {
      fields: [taskDependencies.dependsOnId],
      references: [tasks.id],
      relationName: "task_dependencies_depends_on",
    }),
  }),
);

export const taskEntitiesRelations = relations(taskEntities, ({ one }) => ({
  task: one(tasks, {
    fields: [taskEntities.taskId],
    references: [tasks.id],
  }),
  entity: one(entities, {
    fields: [taskEntities.entityId],
    references: [entities.id],
  }),
}));

export const taskTagsRelations = relations(taskTags, ({ one }) => ({
  task: one(tasks, {
    fields: [taskTags.taskId],
    references: [tasks.id],
  }),
}));

export type Task = typeof tasks.$inferSelect;
export type NewTask = typeof tasks.$inferInsert;

export type Entity = typeof entities.$inferSelect;
export type NewEntity = typeof entities.$inferInsert;

export type TaskDependency = typeof taskDependencies.$inferSelect;
export type NewTaskDependency = typeof taskDependencies.$inferInsert;

export type TaskEntity = typeof taskEntities.$inferSelect;
export type NewTaskEntity = typeof taskEntities.$inferInsert;

export type TaskTag = typeof taskTags.$inferSelect;
export type NewTaskTag = typeof taskTags.$inferInsert;

export type Store = {
  tasks: Task[];
  entities: Entity[];
};
