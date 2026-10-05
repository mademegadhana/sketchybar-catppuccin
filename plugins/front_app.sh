#!/bin/bash
# Shows the icon + name of the focused application.
# $INFO (front_app_switched) = application name.

if [ "$SENDER" = "front_app_switched" ] && [ -n "$INFO" ]; then
  # shellcheck source=../helpers/icon_map.sh
  source "$CONFIG_DIR/helpers/icon_map.sh"
  __icon_map "$INFO"
  sketchybar --set "$NAME" icon="$icon_result" label="$INFO"
fi
