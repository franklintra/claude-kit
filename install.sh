#!/bin/bash

# Install all Claude Code plugins from this repository
# Creates symlinks in ~/.claude/plugins/ for each plugin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_DIR="$HOME/.claude/plugins"

# Create plugins directory if it doesn't exist
mkdir -p "$PLUGINS_DIR"

echo "Installing Claude plugins from: $SCRIPT_DIR"
echo "Target directory: $PLUGINS_DIR"
echo ""

# Find all plugin directories (those containing .claude-plugin/plugin.json)
installed=0
for plugin_manifest in "$SCRIPT_DIR"/*/.claude-plugin/plugin.json; do
    if [[ -f "$plugin_manifest" ]]; then
        plugin_dir="$(dirname "$(dirname "$plugin_manifest")")"
        plugin_name="$(basename "$plugin_dir")"
        target_link="$PLUGINS_DIR/$plugin_name"

        # Remove existing symlink if present
        if [[ -L "$target_link" ]]; then
            rm "$target_link"
        elif [[ -e "$target_link" ]]; then
            echo "Warning: $target_link exists and is not a symlink, skipping..."
            continue
        fi

        # Create symlink
        ln -s "$plugin_dir" "$target_link"
        echo "✓ Installed: $plugin_name"
        ((installed++))
    fi
done

if [[ $installed -eq 0 ]]; then
    echo "No plugins found to install."
    exit 1
fi

echo ""
echo "Done! Installed $installed plugin(s)."
echo ""
echo "To use plugins, launch Claude Code with:"
echo "  claude --plugin-dir ~/.claude/plugins/<plugin-name>"
echo ""
echo "Or add to ~/.claude/settings.json:"
echo '  { "enabledPlugins": { "<plugin-name>": true } }'
