# Claude Plugins

Custom plugins for Claude Code.

## Installation

```bash
./install.sh
```

Then launch Claude with:

```bash
claude --plugin-dir ~/.claude/plugins/usefultools
```

## Plugins

### usefultools

A collection of useful Claude Code commands.

**Commands:**

- `/reviewdiff` - Reviews all git changes (staged, unstaged, untracked) using subagents and suggests what could be done differently
