CREATE TABLE `entities` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`type` text NOT NULL,
	`aliases` text,
	`note` text,
	`created_at` text DEFAULT (datetime('now')) NOT NULL,
	`updated_at` text DEFAULT (datetime('now')) NOT NULL,
	CONSTRAINT "entities_id_not_blank_check" CHECK(length(trim("entities"."id")) > 0),
	CONSTRAINT "entities_name_not_blank_check" CHECK(length(trim("entities"."name")) > 0),
	CONSTRAINT "entities_type_not_blank_check" CHECK(length(trim("entities"."type")) > 0),
	CONSTRAINT "entities_aliases_json_array_check" CHECK("entities"."aliases" is null or (json_valid("entities"."aliases") and json_type("entities"."aliases") = 'array')),
	CONSTRAINT "entities_updated_at_check" CHECK("entities"."updated_at" >= "entities"."created_at")
);
--> statement-breakpoint
CREATE INDEX `entities_name_idx` ON `entities` (`name`);--> statement-breakpoint
CREATE INDEX `entities_type_idx` ON `entities` (`type`);--> statement-breakpoint
CREATE TABLE `task_dependencies` (
	`task_id` text NOT NULL,
	`depends_on_id` text NOT NULL,
	PRIMARY KEY(`task_id`, `depends_on_id`),
	FOREIGN KEY (`task_id`) REFERENCES `tasks`(`id`) ON UPDATE cascade ON DELETE cascade,
	FOREIGN KEY (`depends_on_id`) REFERENCES `tasks`(`id`) ON UPDATE cascade ON DELETE cascade,
	CONSTRAINT "task_dependencies_not_self_check" CHECK("task_dependencies"."task_id" <> "task_dependencies"."depends_on_id")
);
--> statement-breakpoint
CREATE INDEX `task_dependencies_depends_on_id_idx` ON `task_dependencies` (`depends_on_id`);--> statement-breakpoint
CREATE TABLE `task_entities` (
	`task_id` text NOT NULL,
	`entity_id` text NOT NULL,
	PRIMARY KEY(`task_id`, `entity_id`),
	FOREIGN KEY (`task_id`) REFERENCES `tasks`(`id`) ON UPDATE cascade ON DELETE cascade,
	FOREIGN KEY (`entity_id`) REFERENCES `entities`(`id`) ON UPDATE cascade ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `task_entities_entity_id_idx` ON `task_entities` (`entity_id`);--> statement-breakpoint
CREATE TABLE `task_tags` (
	`task_id` text NOT NULL,
	`tag` text NOT NULL,
	PRIMARY KEY(`task_id`, `tag`),
	FOREIGN KEY (`task_id`) REFERENCES `tasks`(`id`) ON UPDATE cascade ON DELETE cascade,
	CONSTRAINT "task_tags_tag_not_blank_check" CHECK(length(trim("task_tags"."tag")) > 0)
);
--> statement-breakpoint
CREATE INDEX `task_tags_tag_idx` ON `task_tags` (`tag`);--> statement-breakpoint
CREATE TABLE `tasks` (
	`id` text PRIMARY KEY NOT NULL,
	`title` text NOT NULL,
	`description` text,
	`status` text NOT NULL,
	`parent_id` text,
	`scheduled_start` text,
	`scheduled_end` text,
	`actual_start` text,
	`actual_end` text,
	`note` text,
	`created_at` text DEFAULT (datetime('now')) NOT NULL,
	`updated_at` text DEFAULT (datetime('now')) NOT NULL,
	`completed_at` text,
	FOREIGN KEY (`parent_id`) REFERENCES `tasks`(`id`) ON UPDATE cascade ON DELETE set null,
	CONSTRAINT "tasks_id_not_blank_check" CHECK(length(trim("tasks"."id")) > 0),
	CONSTRAINT "tasks_title_not_blank_check" CHECK(length(trim("tasks"."title")) > 0),
	CONSTRAINT "tasks_status_check" CHECK("tasks"."status" in ('pending', 'in_progress', 'completed', 'cancelled')),
	CONSTRAINT "tasks_updated_at_check" CHECK("tasks"."updated_at" >= "tasks"."created_at"),
	CONSTRAINT "tasks_completed_at_after_created_check" CHECK("tasks"."completed_at" is null or "tasks"."completed_at" >= "tasks"."created_at"),
	CONSTRAINT "tasks_completion_state_check" CHECK((
        ("tasks"."status" in ('completed', 'cancelled') and "tasks"."completed_at" is not null) or
        ("tasks"."status" in ('pending', 'in_progress') and "tasks"."completed_at" is null)
      )),
	CONSTRAINT "tasks_parent_self_check" CHECK("tasks"."parent_id" is null or "tasks"."parent_id" <> "tasks"."id"),
	CONSTRAINT "tasks_scheduled_window_check" CHECK("tasks"."scheduled_start" is null or "tasks"."scheduled_end" is null or "tasks"."scheduled_start" < "tasks"."scheduled_end"),
	CONSTRAINT "tasks_actual_window_check" CHECK("tasks"."actual_start" is null or "tasks"."actual_end" is null or "tasks"."actual_start" < "tasks"."actual_end")
);
--> statement-breakpoint
CREATE INDEX `tasks_parent_id_idx` ON `tasks` (`parent_id`);--> statement-breakpoint
CREATE INDEX `tasks_status_idx` ON `tasks` (`status`);--> statement-breakpoint
CREATE INDEX `tasks_completed_at_idx` ON `tasks` (`completed_at`);