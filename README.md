# OpenCode-Jarvis 🧠

**OpenCode-Jarvis** is a **minimalist, intelligent task management system** that lives in your terminal.

It strips away complex UIs, clicking, and dragging. Instead, it offers a pure **natural language interface** powered by AI. You simply tell it what you need to do, and it handles the structured data management for you.

> **"It's like having a project manager who lives in your CLI."**

## ✨ Philosophy

- **Zero Friction**: Don't waste time managing the tool. Just chat.
- **Local & Private**: Your data is stored in simple, readable JSON files on your machine. No clouds, no subscriptions.
- **Agent-Native**: Built on the **OpenCode** standard, Jarvis isn't just a script—it's an intelligent agent that understands context, relationships, and time.
- **Transparent**: The agent executes standard CLI commands (`just`, `jq`) under the hood. You can always see exactly what it's doing.

## 💬 How to Use

Jarvis is designed to be used via **Slash Commands** in your agent interface.

### `/task` - The Do-It-All Command

Handle 90% of your workflow without remembering syntax.

- **Create**: "Remind me to check the server logs at 3 PM."
- **Query**: "What tasks do I have for the 'Website' project?"
- **Update**: "Mark the server check as done."

### `/today` - Your Daily Briefing

Start your day with clarity. Jarvis analyzes your schedule, overdue items, and priorities.

- **Input**: `/today`
- **Agent Output**:
  > "Good morning! You have 3 tasks due today. The 'Team Meeting' is at 2 PM. You also have an overdue task from yesterday. Shall I reschedule it?"

### `/review` - Retrospective

Reflect on your progress.

- **Input**: `/review What did I finish this week?`
- **Agent Output**: Generates a summary of completed work and completion rates.

## 🚀 Getting Started

### 1. Installation

Directly paste the following instruction into **OpenCode**:

```text
Clone https://github.com/observerw/OpenCode-Jarvis to ~/.opencode-jarvis, then add `alias jarvis='cd ~/.opencode-jarvis && opencode'` to my shell configuration file (e.g., .bashrc or .zshrc).
```

### 2. Start Chatting

After the setup is complete, simply type `jarvis` in your terminal to start managing your tasks. Jarvis will automatically handle initialization for you.

## ⚙️ Under the Hood

OpenCode-Jarvis is built on a robust, hackable stack:

- **Data Layer**: `data/tasks.json` & `data/entities.json` (Human-readable storage).
- **Execution Engine**: `justfile` (The API layer that the Agent calls).
- **Intelligence**: `.opencode/` (Defines the Agent's personality, commands, and skills).

Because it adheres to the **OpenCode** standard, you can easily customize the agent's behavior or add new skills just by editing Markdown files in `.opencode/`.

## 📄 License

[MIT](LICENSE)
