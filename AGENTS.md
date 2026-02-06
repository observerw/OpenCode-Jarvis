# Jarvis Agentic Development Guidelines

This document provides instructions for agentic coding agents operating in the Jarvis repository. Follow these conventions to ensure consistency, safety, and compatibility.

## 1. Project Overview
Jarvis is a personal task planning and management system. It uses a JSON data layer managed via `just` commands and `jq` expressions.

- **Data Directory:** `data/` (contains `tasks.json` and `entities.json`)
- **Workflow:** OpenSpec (located in `openspec/`)
- **Config:** `config.toml`

## 2. Commands & Operations

### Build & Setup
- **Initialize Data:** `just init` (creates data directory and empty JSON arrays if missing)
- **Check Schema:** `just schema` (displays current Task and Entity structures)
- **Environment Setup:** Use `uv sync` to install Python dependencies in `.venv`.

### Testing & Verification
- **Linting:** `ruff check .` (enforce Python style) and `ruff format .`.
- **Data Validation:** After modifying JSON files, always verify with `jq . <file>` to ensure valid JSON.
- **Data Integrity:** Ensure `id` fields are unique across the respective JSON arrays.
- **Single Test:** If Python tests are added, use `pytest path/to/test.py::test_function_name` for targeted testing.
- **JSON Query Testing:** Test complex `jq` filters on a small subset of data before applying to full files.

### Task Management (CLI)
- **List Tasks:** `just list`
- **Filter by Status:** `just filter-status <pending|done|cancelled>`
- **Filter by Entity:** `just filter-entity <entity_id>`
- **Add Task:** `just add-task "<title>"` or `just add-task "<title>" "<due_at>"`
- **Complete Task:** `just complete-task <id>`
- **Help:** `just help` provides a full list of available query and update commands.

## 3. Code Style & Conventions

### JSON Schema (Tasks)
```json
{
  "id": "task_<timestamp>_<random>",
  "title": "string",
  "content": "string | null",
  "status": "pending | done | cancelled",
  "created_at": "ISO-8601 (YYYY-MM-DDTHH:MM:SS)",
  "due_at": "ISO-8601 | null",
  "completed_at": "ISO-8601 | null",
  "parent_id": "string | null",
  "depends_on": ["string"],
  "entities": ["string"],
  "note": "string | null"
}
```

### JSON Schema (Entities)
```json
{
  "id": "ent_<timestamp>_<random>",
  "type": "person | place | project | tag",
  "name": "string",
  "note": "string | null"
}
```

### Python Guidelines
- **Version:** Targeting Python 3.13+.
- **Imports:** Group imports into standard library, third-party, and local modules. Use absolute imports.
- **Types:** Always use type hints. Use `Pydantic` models for data validation and `Settings` for configuration.
- **Formatting:** Strict adherence to `ruff` default formatting.
- **Naming:** `snake_case` for variables and functions, `PascalCase` for classes, `SCREAMING_SNAKE_CASE` for constants.
- **Error Handling:** Use specific exception types. Wrap external I/O (file, shell) in `try...except` blocks with clear error messages.
- **Pydantic Models:** Define data models in `src/models/` and ensure they match the JSON schema.

### Shell & JQ Guidelines
- **Encapsulation:** Prefer `justfile` recipes over raw shell scripts for common operations.
- **JQ Safety:** Use `--arg` or `--argjson` to pass variables into `jq`. Avoid string interpolation inside `jq` filters.
- **Naming:** Kebab-case for `just` recipes and shell script filenames.

## 4. OpenSpec Workflow
All significant changes must follow the OpenSpec pattern to maintain a clear audit trail and design rationale:
1.  **Research:** Analyze current state and requirements. Search existing `openspec/` for context.
2.  **Proposal:** Create `openspec/changes/<change-name>/proposal.md` explaining "Why" (problem statement) and "What" (high-level solution).
3.  **Spec:** Create `openspec/changes/<change-name>/specs/spec.md` with technical implementation details, API changes, or schema updates.
4.  **Tasks:** Create `openspec/changes/<change-name>/tasks.md` with a checklist of atomic implementation steps.
5.  **Implementation:** Execute tasks sequentially, updating the checklist status.
6.  **Archive:** Once complete and verified, move the entire change directory to `openspec/changes/archive/`.

## 5. Development Safety
- **Atomic Writes:** Use temporary files for JSON updates (`jq ... tasks.json > tasks.json.tmp && mv tasks.json.tmp tasks.json`).
- **Git Safety:** NEVER use `--force` on the main branch. Check `git status` before and after operations.
- **Secrets:** Do not commit `config.toml` if it contains sensitive data. Use `.env` files for local secrets (ensure they are in `.gitignore`).
- **Validation:** Always validate JSON schema after programmatic edits.

## 6. Environment
- **Package Manager:** `uv` is the primary tool for dependency management.
- **Task Runner:** `just` is the primary entry point for all development and operational tasks.
- **Python Env:** Always work within the `.venv` created by `uv`.

## 7. AI Agent Instructions
- **Proactive Initialization:** Always run `just init` if the `data/` directory is missing.
- **Semantic Understanding:** Interpret natural language requests into structured JSON operations based on the core schema.
- **Context Awareness:** Before making changes, read relevant `openspec/` documents to understand existing design decisions.
- **Feedback Loop:** Verify every change with a corresponding `just` query or `jq` validation step.
- **Atomic Modification:** Ensure that when updating lists (like `depends_on` or `entities`), you check for existence before adding to avoid duplicates.
- **Status Management:** Transitioning a task to `done` should always set `completed_at` to the current UTC timestamp in ISO-8601 format.
- **Entity Linking:** When creating a task that refers to a person or project, search `entities.json` first to see if a matching entity already exists. If not, prompt to create one.
- **Dependency Safety:** Before marking a task as `done`, check if it has any `depends_on` tasks that are still `pending`.

## 8. Git Commit Guidelines
- Use descriptive, present-tense commit messages (e.g., "add task dependency logic", "fix jq filter for overdue tasks").
- Prefix commits with the component name if applicable (e.g., "justfile: add filter-entity recipe").
- Ensure all changes are linted and validated before committing.
- Avoid large commits; prefer small, focused commits corresponding to OpenSpec tasks.

## 9. Project Structure
- `data/`: JSON storage for tasks and entities.
- `openspec/`: Design documents and change tracking.
- `src/`: Python source code (to be developed).
- `config.toml`: Application configuration.
- `justfile`: Task automation recipes.
- `pyproject.toml`: Python dependency and tool configuration.

## 10. Data Management
- Always check for ID collisions before inserting new records.
- Use `ISO-8601` format without timezone offsets (assume UTC) for all timestamps.
- When deleting a task, check if it is a parent of other tasks and handle orphans accordingly (prompt user or clear `parent_id`).
- When deleting an entity, search all tasks to remove the reference from the `entities` array.
