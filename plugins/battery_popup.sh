#!/bin/bash
# Fills the battery popup with details from pmset / ioreg.
batt=$(pmset -g batt)
pct=$(printf '%s' "$batt" | grep -Eo '[0-9]+%' | head -1)
state=$(printf '%s' "$batt" | grep -Eo '(charging|discharging|charged|finishing charge|AC attached)' | head -1)
remain=$(printf '%s' "$batt" | grep -Eo '[0-9]+:[0-9]+ remaining' | head -1)
cycles=$(ioreg -r -c AppleSmartBattery | awk -F'= ' '/"CycleCount" =/{print $2; exit}')
maxcap=$(ioreg -r -c AppleSmartBattery | awk -F'= ' '/"AppleRawMaxCapacity" =/{m=$2} /"DesignCapacity" =/{d=$2} END{if(d>0) printf "%d%%", m*100/d}')
case "$state" in
  charging) st="Mengisi daya" ;; discharging) st="Pakai baterai" ;;
  charged|"finishing charge") st="Penuh / hampir penuh" ;; *) st="${state:-Terhubung listrik}" ;;
esac
[ -z "$remain" ] && remain="menghitung..."
row() { printf '%s\n' --add item "battery.p.$1" popup.battery --set "battery.p.$1" icon.drawing=off background.drawing=off "label=$2" label.padding_left=10 label.padding_right=10; }
mapfile_args=()
while IFS= read -r a; do mapfile_args+=("$a"); done < <(
  row 1 "Baterai: $pct  ($st)"
  row 2 "Sisa waktu: ${remain% remaining}"
  row 3 "Kesehatan: ${maxcap:-?}   Siklus: ${cycles:-?}"
  printf '%s\n' --add item battery.p.4 popup.battery --set battery.p.4 icon.drawing=off background.drawing=off "label=Pengaturan Baterai" label.padding_left=10 label.color=0xffcba6f7 "click_script=open 'x-apple.systempreferences:com.apple.Battery-Settings.extension'; sketchybar --set battery popup.drawing=off"
)
sketchybar --remove '/battery\.p\..*/' "${mapfile_args[@]}" --set battery popup.drawing=toggle
