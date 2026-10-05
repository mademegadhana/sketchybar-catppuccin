#!/bin/bash
# Highlights the focused AeroSpace workspace and shows its app icons.
# shellcheck source=../colors.sh
source "$CONFIG_DIR/colors.sh"
# shellcheck source=../helpers/icon_map.sh
source "$CONFIG_DIR/helpers/icon_map.sh"

AS=/opt/homebrew/bin/aerospace
sid="${NAME#space.}"
focused="${FOCUSED_WORKSPACE:-$($AS list-workspaces --focused 2>/dev/null)}"

icons=""
while IFS= read -r app; do
  [ -n "$app" ] || continue
  __icon_map "$app"
  icons="$icons $icon_result"
done < <($AS list-windows --workspace "$sid" --format '%{app-name}' 2>/dev/null | sort -u)

args=()
if [ -n "$icons" ]; then
  args+=(label="${icons# }" label.drawing=on drawing=on)
else
  args+=(label="" label.drawing=off)
fi

if [ "$sid" = "$focused" ]; then
  args+=(drawing=on background.color="$ACCENT_COLOR" icon.highlight=on label.highlight=on)
else
  args+=(background.color="$ITEM_BG_COLOR" icon.highlight=off label.highlight=off)
  # Sembunyikan workspace kosong yang tidak aktif
  [ -z "$icons" ] && args+=(drawing=off)
fi

sketchybar --set "$NAME" "${args[@]}"
