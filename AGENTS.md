This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Custom plugins for Claude Code. Plugins extend Claude Code with new slash commands.

## Installation

```bash
./install.sh
```

Requires `jq`. Creates a local marketplace at `~/.claude/plugins/marketplaces/local/`. Restart Claude Code after installing.

## Plugin Structure

```
<plugin-name>/
├── .claude-plugin/
│   └── plugin.json      # Required manifest
└── commands/
    └── <command>.md     # Plain markdown (no YAML frontmatter)
```

Command files are plain markdown starting with a heading. The filename becomes the command name.

## Current Commands (kit)

- `/kit:ship` - Stages only files you changed in this conversation (or all if fresh), auto-generates a conventional commit, and pushes
- `/kit:review` - Spawns subagents to analyze your git diff in context, assess approach quality, and suggest concrete improvements
- `/kit:syncmd` - Spawns subagents to scan the codebase and update AGENTS.md (+ other docs) to reflect current state

## Adding New Commands

1. Create `kit/commands/<name>.md` (filename = command name)
2. Write markdown content starting with a `# Heading`
3. Run `./install.sh`
4. Restart Claude Code

## How install.sh Works

The install script:
1. Scans for plugins (directories with `.claude-plugin/plugin.json`)
2. Copies them to `~/.claude/plugins/marketplaces/local/`
3. Registers the marketplace in `known_marketplaces.json`
4. Enables plugins in `~/.claude/settings.json`
5. Updates `installed_plugins.json` with plugin metadata
