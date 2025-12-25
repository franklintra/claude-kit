#!/bin/bash

# Install all Claude Code plugins from this repository
# Creates a local marketplace at ~/.claude/plugins/marketplaces/local/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_DIR="$HOME/.claude/plugins"
MARKETPLACE_DIR="$PLUGINS_DIR/marketplaces/local"
MARKETPLACE="local"

if ! command -v jq &> /dev/null; then
    echo "Error: jq is required. Install with: brew install jq"
    exit 1
fi

echo "Installing Claude plugins from: $SCRIPT_DIR"
echo ""

# Create marketplace structure
mkdir -p "$MARKETPLACE_DIR/.claude-plugin"
mkdir -p "$MARKETPLACE_DIR/plugins"

# Build plugins array for marketplace.json
plugins_json="[]"
installed=0
discovered_commands=""

for plugin_manifest in "$SCRIPT_DIR"/*/.claude-plugin/plugin.json; do
    if [[ -f "$plugin_manifest" ]]; then
        plugin_dir="$(dirname "$(dirname "$plugin_manifest")")"
        plugin_name="$(basename "$plugin_dir")"
        plugin_version=$(jq -r '.version // "1.0.0"' "$plugin_manifest")
        plugin_desc=$(jq -r '.description // ""' "$plugin_manifest")

        # Copy plugin to marketplace
        target_dir="$MARKETPLACE_DIR/plugins/$plugin_name"
        rm -rf "$target_dir"
        mkdir -p "$target_dir"
        cp -r "$plugin_dir"/. "$target_dir/"

        # Build commands array and collect command info for display
        commands_json="[]"
        for cmd_file in "$target_dir"/commands/*.md; do
            if [[ -f "$cmd_file" ]]; then
                cmd_basename=$(basename "$cmd_file" .md)
                cmd_desc=$(head -1 "$cmd_file" | sed 's/^# *//')
                commands_json=$(echo "$commands_json" | jq --arg cmd "./commands/$cmd_basename.md" '. + [$cmd]')
                discovered_commands+="/$plugin_name:$cmd_basename|$cmd_desc|plugin:$plugin_name@$MARKETPLACE"$'\n'
            fi
        done

        # Add plugin entry
        plugin_entry=$(jq -n \
            --arg name "$plugin_name" \
            --arg source "./plugins/$plugin_name" \
            --arg desc "$plugin_desc" \
            --arg version "$plugin_version" \
            --argjson commands "$commands_json" \
            '{name: $name, source: $source, description: $desc, version: $version, commands: $commands}')

        plugins_json=$(echo "$plugins_json" | jq --argjson entry "$plugin_entry" '. + [$entry]')

        echo "✓ Installed: $plugin_name (v$plugin_version)"
        ((installed++))
    fi
done

if [[ $installed -eq 0 ]]; then
    echo "No plugins found to install."
    exit 1
fi

# Create marketplace.json
jq -n \
    --arg name "$MARKETPLACE" \
    --argjson plugins "$plugins_json" \
    '{name: $name, owner: {name: "local"}, metadata: {description: "Local plugins", version: "1.0.0"}, plugins: $plugins}' \
    > "$MARKETPLACE_DIR/.claude-plugin/marketplace.json"

echo ""

# Register marketplace in known_marketplaces.json
MARKETPLACES_FILE="$PLUGINS_DIR/known_marketplaces.json"
[[ ! -f "$MARKETPLACES_FILE" ]] && echo '{}' > "$MARKETPLACES_FILE"

jq --arg path "$MARKETPLACE_DIR" \
   '.local = {source: {source: "directory", path: $path}, installLocation: $path, lastUpdated: (now | strftime("%Y-%m-%dT%H:%M:%S.000Z"))}' \
   "$MARKETPLACES_FILE" > "$MARKETPLACES_FILE.tmp" && mv "$MARKETPLACES_FILE.tmp" "$MARKETPLACES_FILE"
echo "✓ Registered marketplace"

# Update settings.json to enable plugins
SETTINGS_FILE="$HOME/.claude/settings.json"
[[ ! -f "$SETTINGS_FILE" ]] && echo '{}' > "$SETTINGS_FILE"

for plugin_manifest in "$SCRIPT_DIR"/*/.claude-plugin/plugin.json; do
    if [[ -f "$plugin_manifest" ]]; then
        plugin_name="$(basename "$(dirname "$(dirname "$plugin_manifest")")")"
        full_name="$plugin_name@$MARKETPLACE"
        jq --arg name "$full_name" '.enabledPlugins[$name] = true' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    fi
done
echo "✓ Enabled plugins"

# Update installed_plugins.json
INSTALLED_FILE="$PLUGINS_DIR/installed_plugins.json"
[[ ! -f "$INSTALLED_FILE" ]] && echo '{"version": 2, "plugins": {}}' > "$INSTALLED_FILE"

current_time=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

for plugin_manifest in "$SCRIPT_DIR"/*/.claude-plugin/plugin.json; do
    if [[ -f "$plugin_manifest" ]]; then
        plugin_dir="$(dirname "$(dirname "$plugin_manifest")")"
        plugin_name="$(basename "$plugin_dir")"
        plugin_version=$(jq -r '.version // "1.0.0"' "$plugin_manifest")
        full_name="$plugin_name@$MARKETPLACE"
        install_path="$MARKETPLACE_DIR/plugins/$plugin_name"

        plugin_entry=$(jq -n \
            --arg scope "user" \
            --arg installPath "$install_path" \
            --arg version "$plugin_version" \
            --arg installedAt "$current_time" \
            --arg lastUpdated "$current_time" \
            '[{scope: $scope, installPath: $installPath, version: $version, installedAt: $installedAt, lastUpdated: $lastUpdated, isLocal: true}]')

        jq --arg name "$full_name" --argjson entry "$plugin_entry" '.plugins[$name] = $entry' "$INSTALLED_FILE" > "$INSTALLED_FILE.tmp" && mv "$INSTALLED_FILE.tmp" "$INSTALLED_FILE"
    fi
done
echo "✓ Registered plugins"

# Print discovered commands
if [[ -n "$discovered_commands" ]]; then
    echo ""
    echo "Commands:"
    echo "$discovered_commands" | while IFS='|' read -r cmd desc source; do
        [[ -z "$cmd" ]] && continue
        printf "  %-20s %-35s (%s)\n" "$cmd" "$desc" "$source"
    done
fi

echo ""
echo "Done! Installed $installed plugin(s). Restart Claude Code to use them."
