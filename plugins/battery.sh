#!/bin/bash
# Battery percentage + charging state via pmset.

# shellcheck source=../colors.sh
source "$CONFIG_DIR/colors.sh"
# shellcheck source=../icons.sh
source "$CONFIG_DIR/icons.sh"

batt_info="$(pmset -g batt)"
percentage="$(printf '%s' "$batt_info" | grep -Eo '[0-9]+%' | head -n1 | tr -d '%')"
charging="$(printf '%s' "$batt_info" | grep -c 'AC Power')"

if [ -z "$percentage" ]; then
  sketchybar --set "$NAME" drawing=off   # no battery (should not happen on a MacBook)
  exit 0
fi

color="$GREEN"
case "$percentage" in
  100|9[0-9]|8[0-9]) icon="$BATTERY_100" ;;
  7[0-9]|6[0-9])     icon="$BATTERY_75" ;;
  5[0-9]|4[0-9])     icon="$BATTERY_50"; color="$YELLOW" ;;
  3[0-9]|2[0-9])     icon="$BATTERY_25"; color="$ORANGE" ;;
  *)                 icon="$BATTERY_0";  color="$RED" ;;
esac

if [ "$charging" -gt 0 ]; then
  icon="$BATTERY_CHARGING"
  color="$GREEN"
fi

sketchybar --set "$NAME" drawing=on icon="$icon" icon.color="$color" label="${percentage}%"
