# Claude Kit

Slash commands that save you keystrokes in [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Commands

### `/kit:ship`
Stages your changes, writes a [conventional commit](https://www.conventionalcommits.org/) message, and pushes. Knows which files you touched in the current conversation—won't accidentally commit unrelated work.

### `/kit:review`
Reviews your diff like a second pair of eyes. Spawns subagents to explore the surrounding codebase, then gives you concrete feedback on approach, edge cases, and alternatives.

### `/kit:draft`
Creates a branch and PR from your local changes. Analyzes the diff to generate smart branch names (like `feat/add-user-auth`) and PR descriptions. Accepts an optional target branch argument.

### `/kit:syncmd`
Crawls your codebase and updates documentation to match reality. Handles `README.md`, `CLAUDE.md`, `AGENTS.md`, and any other markdown files it finds.

## Install

```bash
git clone https://github.com/franklintra/claude-kit.git
cd claude-kit
./install.sh
```

Requires `jq` (`brew install jq` on macOS). Restart Claude Code after installing.

## Create Your Own Commands

Commands are just markdown files:

```
kit/
├── .claude-plugin/
│   └── plugin.json      # name, version, description
└── commands/
    └── deploy.md        # becomes /kit:deploy
```

The markdown content is the prompt Claude follows when you invoke the command. See [`kit/commands/`](kit/commands/) for examples.

## Contributing

PRs welcome. Add your command to `kit/commands/` and open a pull request.

## License

MIT
