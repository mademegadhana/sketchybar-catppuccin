#!/bin/bash
# Shows app icons (sketchybar-app-font) for every window on a space.
# $INFO (space_windows_change) looks like:
#   {"space": 2, "apps": {"Safari": 1, "Visual Studio Code": 2}}
# Parsed without jq so it works on a stock macOS.

[ "$SENDER" = "space_windows_change" ] || exit 0

# shellcheck source=../helpers/icon_map.sh
source "$CONFIG_DIR/helpers/icon_map.sh"

space="$(printf '%s' "$INFO" | sed -nE 's/.*"space"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p')"
[ -n "$space" ] || exit 0

apps_json="$(printf '%s' "$INFO" | sed -nE 's/.*"apps"[[:space:]]*:[[:space:]]*\{(.*)\}.*/\1/p')"

icon_strip=""
while IFS= read -r app; do
  [ -n "$app" ] || continue
  __icon_map "$app"
  icon_strip="$icon_strip $icon_result"
done < <(printf '%s' "$apps_json" \
           | grep -oE '"([^"\\]|\\.)*"[[:space:]]*:[[:space:]]*[0-9]+' \
           | sed -E 's/^"(.*)"[[:space:]]*:[[:space:]]*[0-9]+$/\1/')

if [ -n "$icon_strip" ]; then
  sketchybar --set "space.$space" label="${icon_strip# }" label.drawing=on
else
  sketchybar --set "space.$space" label="" label.drawing=off
fi
