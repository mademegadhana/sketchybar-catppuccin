#!/bin/bash
# Highlights the active Mission Control space.
# $SELECTED is provided by sketchybar for items of type "space".

# shellcheck source=../colors.sh
source "$CONFIG_DIR/colors.sh"

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" background.color="$ACCENT_COLOR" \
                           icon.highlight=on \
                           label.highlight=on
else
  sketchybar --set "$NAME" background.color="$ITEM_BG_COLOR" \
                           icon.highlight=off \
                           label.highlight=off
fi
