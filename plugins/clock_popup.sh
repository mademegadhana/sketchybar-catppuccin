#!/bin/bash
# Fills the clock popup with this month's calendar (today marked with [ ]).
d=$(date +%e | tr -d ' ')
i=0
args=(--remove '/clock\.cal\..*/')
while IFS= read -r line; do
  [ $i -gt 0 ] && line=$(printf '%s' " $line " | sed -E "s/ ${d} / [${d}]/; s/^ //")
  args+=(--add item "clock.cal.$i" popup.clock
         --set "clock.cal.$i" icon.drawing=off background.drawing=off
               label="$line" label.font="Hack Nerd Font Mono:Regular:12.0"
               label.padding_left=10 label.padding_right=10)
  i=$((i+1))
done < <(cal | sed '/^ *$/d')
args+=(--add item clock.cal.open popup.clock
       --set clock.cal.open icon.drawing=off label="Buka Kalender" background.drawing=off
             label.padding_left=10 label.color=0xffcba6f7
             click_script="open -a Calendar; sketchybar --set clock popup.drawing=off")
sketchybar "${args[@]}" --set clock popup.drawing=toggle
