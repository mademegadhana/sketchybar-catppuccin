#!/bin/bash
# Total CPU usage (sum of all processes / number of cores). Cheap, no `top`.

# shellcheck source=../colors.sh
source "$CONFIG_DIR/colors.sh"

cores="$(sysctl -n hw.ncpu 2>/dev/null)"
cores="${cores:-1}"

usage="$(ps -A -o %cpu= | awk -v c="$cores" '{s += $1} END {u = s / c; if (u > 100) u = 100; printf "%d", u}')"
usage="${usage:-0}"

if [ "$usage" -ge 80 ]; then
  color="$RED"
elif [ "$usage" -ge 50 ]; then
  color="$ORANGE"
else
  color="$GREEN"
fi

sketchybar --set "$NAME" label="${usage}%" icon.color="$color"
