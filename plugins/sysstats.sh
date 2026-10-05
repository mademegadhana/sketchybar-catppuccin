#!/bin/bash
# Memory usage and CPU temperature via macmon (no sudo needed on Apple Silicon).
# Hardened against sleep/wake: timeout on macmon, no overlapping runs,
# sanity-checked values, memory fallback via vm_stat, refresh on wake.

source "$CONFIG_DIR/colors.sh"

LOCK=/tmp/sketchybar_sysstats.lock
STATE=/tmp/sketchybar_sysstats.last

if [ "$SENDER" = "system_woke" ]; then
  # macmon runs left hanging across sleep would block updates: clear them.
  pkill -f "macmon pipe" 2>/dev/null
  rm -rf "$LOCK"
  sleep 3
fi

# Skip if a previous run is still going (but break a lock older than 20s).
if ! mkdir "$LOCK" 2>/dev/null; then
  age=$(( $(date +%s) - $(stat -f %m "$LOCK" 2>/dev/null || echo 0) ))
  [ "$age" -lt 20 ] && exit 0
  pkill -f "macmon pipe" 2>/dev/null; rm -rf "$LOCK"; mkdir "$LOCK" 2>/dev/null || exit 0
fi
trap 'rm -rf "$LOCK"' EXIT

# Run macmon with a hard 4-second limit.
json="$(/usr/bin/perl -e 'alarm 4; exec @ARGV' /opt/homebrew/bin/macmon pipe -s 1 -i 300 2>/dev/null)"

mem=""; temp=""
if [ -n "$json" ]; then
  read -r mem temp <<<"$(printf '%s' "$json" | /usr/bin/jq -r '[((.memory.ram_usage // 0) / (.memory.ram_total // 1) * 100 | floor), ((.temp.cpu_temp_avg // 0) | floor)] | @tsv' 2>/dev/null)"
fi

isnum() { [[ "$1" =~ ^[0-9]+$ ]]; }

# Memory fallback from vm_stat (app + wired + compressed, like Activity Monitor).
if ! isnum "$mem" || [ "$mem" -le 0 ] || [ "$mem" -gt 100 ]; then
  total=$(sysctl -n hw.memsize)
  mem=$(vm_stat | awk -v t="$total" '/page size of/ {ps=$8}
    /Anonymous pages/ {a=$3} /Pages wired down/ {w=$4} /occupied by compressor/ {c=$5}
    /Pages purgeable/ {p=$3}
    END {gsub(/\./,"",a); gsub(/\./,"",w); gsub(/\./,"",c); gsub(/\./,"",p);
         printf "%d", ((a-p)+w+c)*ps/t*100}')
fi

# Temperature: keep the last good reading if this one is missing or nonsense.
last_temp=""; [ -f "$STATE" ] && last_temp="$(cat "$STATE")"
if isnum "$temp" && [ "$temp" -ge 15 ] && [ "$temp" -le 115 ]; then
  echo "$temp" > "$STATE"
else
  temp="$last_temp"
fi

args=()
if isnum "$mem" && [ "$mem" -gt 0 ] && [ "$mem" -le 100 ]; then
  if [ "$mem" -ge 85 ]; then mcolor="$RED"; elif [ "$mem" -ge 70 ]; then mcolor="$ORANGE"; else mcolor="$BLUE"; fi
  args+=(--set memory label="${mem}%" icon.color="$mcolor")
fi
if isnum "$temp"; then
  if [ "$temp" -ge 85 ]; then tcolor="$RED"; elif [ "$temp" -ge 70 ]; then tcolor="$ORANGE"; else tcolor="$GREEN"; fi
  args+=(--set temp label="${temp}°C" icon.color="$tcolor")
fi
[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"
exit 0
