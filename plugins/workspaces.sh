#!/bin/bash
# One observer for all AeroSpace workspaces:
# 1) keeps workspaces packed 1..N (closing #4 makes #5 become #4)
# 2) redraws space.1..space.9 in a single sketchybar call.
# shellcheck source=../colors.sh
source "$CONFIG_DIR/colors.sh"
# shellcheck source=../helpers/icon_map.sh
source "$CONFIG_DIR/helpers/icon_map.sh"

AS=/opt/homebrew/bin/aerospace
LOCK=/tmp/sketchybar_workspaces.lock
mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rmdir "$LOCK"' EXIT

focused="$($AS list-workspaces --focused 2>/dev/null)" || exit 0
[ -n "$focused" ] || exit 0

# --- pack workspaces ---
used=$($AS list-windows --all --format '%{workspace}' 2>/dev/null | grep -E '^[1-9]$' | sort -un)
n=1; newfocus="$focused"
for ws in $used; do
  if [ "$ws" != "$n" ]; then
    for wid in $($AS list-windows --workspace "$ws" --format '%{window-id}'); do
      $AS move-node-to-workspace --window-id "$wid" "$n"
    done
    [ "$ws" = "$focused" ] && newfocus="$n"
  fi
  n=$((n+1))
done
count=$((n-1))
# focused on an empty workspace far past the end -> go to the next free one
if ! printf '%s\n' $used | grep -qx "$focused" && [ "$focused" -gt $((count+1)) ] 2>/dev/null; then
  newfocus=$((count+1))
fi
[ "$newfocus" != "$focused" ] && $AS workspace "$newfocus" && focused="$newfocus"

# --- redraw ---
args=()
for sid in 1 2 3 4 5 6 7 8 9; do
  icons=""
  while IFS= read -r app; do
    [ -n "$app" ] || continue
    __icon_map "$app"; icons="$icons $icon_result"
  done < <($AS list-windows --workspace "$sid" --format '%{app-name}' 2>/dev/null | sort -u)
  set=(--set "space.$sid")
  if [ -n "$icons" ]; then set+=(label="${icons# }" label.drawing=on drawing=on)
  else set+=(label="" label.drawing=off); fi
  if [ "$sid" = "$focused" ]; then
    set+=(drawing=on background.color="$ACCENT_COLOR" icon.highlight=on label.highlight=on)
  else
    set+=(background.color="$ITEM_BG_COLOR" icon.highlight=off label.highlight=off)
    [ -z "$icons" ] && set+=(drawing=off)
  fi
  args+=("${set[@]}")
done
sketchybar "${args[@]}"
