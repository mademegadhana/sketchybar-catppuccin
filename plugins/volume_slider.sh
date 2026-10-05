#!/bin/bash
# Hover slider for volume, with smooth open/close and smooth level changes.
FLAG="/tmp/sketchybar_volume_slider_hover"

expand()   { sketchybar --animate sin 25 --set volume_slider slider.width=110 slider.knob.drawing=on padding_left=6 padding_right=4; }
collapse() { sketchybar --animate sin 25 --set volume_slider slider.width=0 slider.knob.drawing=off padding_left=0 padding_right=0; }

case "$SENDER" in
  volume_change)
    sketchybar --animate tanh 20 --set "$NAME" slider.percentage="$INFO" \
               --set volume label="${INFO}%" ;;
  mouse.clicked)
    sketchybar --set "$NAME" slider.percentage="$PERCENTAGE" \
               --set volume label="${PERCENTAGE}%"
    osascript -e "set volume output volume $PERCENTAGE" & ;;
  mouse.entered|mouse.exited)
    exec "$CONFIG_DIR/plugins/volume_hover.sh" ;;
  expand) expand ;;
  collapse_if_idle)
    sleep 0.8
    [ -f "$FLAG" ] || collapse ;;
esac
