# Jarvis-Task

![README Banner](assets/banner.png)

[![Powered by opencode](https://img.shields.io/badge/Powered%20by-opencode-blue?logo=opencode&logoColor=white&link=https://opencode.ai/)](https://opencode.ai/)

**Jarvis-Task** is a **minimalist, intelligent task management assistant** that lives in your terminal.

> **"A project manager that lives in your CLI."**

It eliminates the friction of complex UIs, clicking, and dragging by providing a pure **natural language interface**. You simply tell Jarvis what you need to do, and it handles the structured data management, scheduling, and tracking for you.

## 🚀 Getting Started

### 0. Prerequisites

This project is powered by the great [OpenCode](https://opencode.ai/) agent (for now). Make sure you have OpenCode installed and set up on your machine:

```bash
bun i -g opencode-ai
```

### 1. Installation

Copy paste the following prompt to one of your OpenCode agent:

````text

Please help me intall Jarvis-Task. First, Clone the repository:

```bash
git clone https://github.com/observerw/OpenCode-Jarvis ~/.jarvis-task
```

Then, ask me if I want to add an alias to the shell config(.zshrc, .bashrc, etc.):

```bash
echo "alias jarvis='cd ~/.jarvis-task && opencode'" >> ~/.zshrc
source ~/.zshrc
```
````

### 2. Start Managing

Type `jarvis` in your terminal to begin. Jarvis automatically handles initialization and data setup on its first run.

## 💬 How to Use

Jarvis is designed to understand your intent through natural conversation and specialized commands.

### `/task` - The Core Engine

Handle 90% of your workflow with simple language.

- **Create**: "Remind me to check the server logs at 3 PM."
- **Query**: "What tasks do I have for the 'Website' project?"
- **Update**: "Mark the server check as done."

### `/today` - Daily Briefing

Start your day with clarity. Jarvis analyzes your schedule, overdue items, and priorities to give you a concise briefing.

- **Input**: `/today`
- **Output**: _"Good morning! You have 3 tasks due today. The 'Team Meeting' is at 2 PM. You also have an overdue task from yesterday. Shall I reschedule it?"_

### `/review` - Progress Analytics

Reflect on your productivity.

- **Input**: `/review What did I finish this week?`
- **Output**: Generates a summary of completed work, completion rates, and focus areas.

## ⚙️ Design & Architecture

Jarvis-Task is built to be robust, transparent, and hackable:

- **Local Storage**: Data is kept in `data/tasks.json` and `data/entities.json`. It's your data, stored in human-readable formats.
- **Task Runner**: Uses `just` and `jq` for high-performance data queries and updates.
- **Customizable**: The system's logic and personality are defined in the internal configuration, allowing for easy extension.

## ✨ Philosophy

- **Zero Friction**: Don't waste time learning a task management tool. If you can describe it, Jarvis can track it.
- **Privacy First**: Everything stays on your machine. No cloud sync, no subscriptions, no tracking.
- **Context-Aware**: Jarvis understands relationships between tasks, people, and projects, not just isolated line items.
- **Transparent Execution**: You can always see the commands being run under the hood. No "black box" logic.

## 📄 License

[MIT](LICENSE)
