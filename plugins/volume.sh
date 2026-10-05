#!/bin/bash
# Volume level (volume_change event). Click = mute toggle, scroll = +/- volume.

# shellcheck source=../icons.sh
source "$CONFIG_DIR/icons.sh"

case "$SENDER" in
  mouse.entered|mouse.exited)
    exec "$CONFIG_DIR/plugins/volume_hover.sh" ;;
  mouse.clicked)
    osascript -e 'set volume output muted (not (output muted of (get volume settings)))'
    exit 0 ;;
  mouse.scrolled)
    delta="${SCROLL_DELTA:-0}"
    cur="$(sketchybar --query volume | sed -nE 's/.*"value": *"([0-9]+)%".*/\1/p' | head -1)"
    new=$(( ${cur:-50} + delta )); [ $new -lt 0 ] && new=0; [ $new -gt 100 ] && new=100
    sketchybar --set volume label="${new}%" --set volume_slider slider.percentage="$new"
    osascript -e "set volume output volume $new" &
    exit 0 ;;
esac

if [ "$SENDER" = "volume_change" ] && [ -n "$INFO" ]; then
  volume="$INFO"
else
  volume="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)"
fi

# "missing value" is returned when the output device has no volume control
case "$volume" in
  ''|*[!0-9]*) volume=0 ;;
esac

muted="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"

if [ "$muted" = "true" ] || [ "$volume" -eq 0 ]; then
  icon="$VOLUME_0"
elif [ "$volume" -ge 66 ]; then
  icon="$VOLUME_100"
elif [ "$volume" -ge 33 ]; then
  icon="$VOLUME_66"
else
  icon="$VOLUME_33"
fi

sketchybar --set "$NAME" icon="$icon" label="${volume}%" \
           --animate tanh 20 --set volume_slider slider.percentage="$volume"
