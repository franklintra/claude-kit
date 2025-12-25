Claude Code plugins repo. Commands are markdown files in `kit/commands/`.

## Structure

```
kit/
├── .claude-plugin/plugin.json
└── commands/
    ├── draft.md     → /kit:draft
    ├── review.md    → /kit:review
    ├── ship.md      → /kit:ship
    └── syncmd.md    → /kit:syncmd
```

## Adding Commands

1. Create `kit/commands/<name>.md` (filename = command name)
2. First line must be `# Short description` — this is shown in the Claude Code CLI
3. Run `./install.sh`, restart Claude Code
