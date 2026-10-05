#!/bin/bash
# Fast hover handler shared by the volume box (icon+label) and the slider.
# Uses one flag per item; slider stays open while either is hovered.
D=/tmp/sketchybar_vol_hover; mkdir -p "$D"
open_s()  { sketchybar --animate sin 18 --set volume_slider slider.width=110 slider.knob.drawing=on padding_left=6 padding_right=4; }
close_s() { sketchybar --animate sin 18 --set volume_slider slider.width=0 slider.knob.drawing=off padding_left=0 padding_right=0; }
case "$SENDER" in
  mouse.entered) touch "$D/$NAME"; open_s ;;
  mouse.exited)
    rm -f "$D/$NAME"
    ( sleep 0.25; [ -z "$(ls -A "$D")" ] && close_s ) & ;;
esac
