#!/bin/bash
# Wi-Fi popup: hover/click on the wifi item shows saved networks; click one to join.
D=/tmp/sketchybar_wifi_hover; mkdir -p "$D"
IF=en0

rescan() {
  ( open -g -W "$HOME/Applications/SketchyWiFi.app" && SENDER=rescan_done NAME=wifi "$CONFIG_DIR/plugins/wifi_popup.sh" ) >/dev/null 2>&1 &
}

ensure_items() {
  # Create all popup slots once; afterwards only update them in place (no flicker).
  sketchybar --query wifi.p.settings >/dev/null 2>&1 && return
  common=(icon.drawing=off background.drawing=off label.padding_left=12 label.padding_right=12
          script="$CONFIG_DIR/plugins/wifi_popup.sh")
  a=(--add item wifi.p.toggle popup.wifi --set wifi.p.toggle "${common[@]}" label.color=0xffcba6f7
     --subscribe wifi.p.toggle mouse.entered mouse.exited
     --add item wifi.p.scan popup.wifi --set wifi.p.scan "${common[@]}" drawing=off
     --subscribe wifi.p.scan mouse.entered mouse.exited)
  for n in 0 1 2 3 4 5 6 7 8 9; do
    a+=(--add item "wifi.p.$n" popup.wifi --set "wifi.p.$n" "${common[@]}" drawing=off icon.drawing=on
        icon.font="Hack Nerd Font:Regular:15.0" icon.width=22 icon.align=center icon.y_offset=1
        icon.padding_left=10 icon.padding_right=6 label.padding_left=0 label.padding_right=14 label.color=0xffffffff
        --subscribe "wifi.p.$n" mouse.entered mouse.exited)
  done
  a+=(--add item wifi.p.settings popup.wifi --set wifi.p.settings "${common[@]}" label="Pengaturan Wi-Fi..."
      label.color=0xff9399b2
      click_script="open 'x-apple.systempreferences:com.apple.wifi-settings-extension'; sketchybar --set wifi popup.drawing=off"
      --subscribe wifi.p.settings mouse.entered mouse.exited)
  sketchybar "${a[@]}"
}

build() {
  ensure_items
  cur="$(sketchybar --query wifi | /usr/bin/jq -r .label.value)"
  power="$(networksetup -getairportpower $IF | awk '{print $NF}')"
  saved="$(networksetup -listpreferredwirelessnetworks $IF 2>/dev/null | sed 's/^[[:space:]]*//')"
  if [ "$power" = "On" ]; then tlabel="Matikan Wi-Fi"; tcmd="Off"; else tlabel="Nyalakan Wi-Fi"; tcmd="On"; fi
  args=(--set wifi.p.toggle label="$tlabel"
        click_script="networksetup -setairportpower $IF $tcmd; sketchybar --set wifi popup.drawing=off; sleep 3; sketchybar --trigger wifi_change")
  SCAN=/tmp/sketchybar_wifi_scan.txt
  if [ ! -s "$SCAN" ]; then
    args+=(--set wifi.p.scan drawing=on label="    Memindai jaringan..." label.color=0xff9399b2 click_script="")
  elif grep -q '^#DENIED' "$SCAN"; then
    args+=(--set wifi.p.scan drawing=on label="    Izinkan Lokasi untuk SketchyWiFi" label.color=0xfffab387
           click_script="open 'x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices'")
  else
    args+=(--set wifi.p.scan drawing=off)
  fi
  i=0
  while IFS=$'\t' read -r ssid rssi secure; do
    [ -n "$ssid" ] || continue
    case "$ssid" in \#*) continue ;; esac
    if [ "$rssi" -ge -55 ]; then sig="󰤨"; elif [ "$rssi" -ge -67 ]; then sig="󰤥"; elif [ "$rssi" -ge -78 ]; then sig="󰤢"; else sig="󰤟"; fi
    lock=""; [ "$secure" = "1" ] && lock="  􀎡"
    if [ "$ssid" = "$cur" ]; then icol=0xffa6e3a1; lfont="SF Pro:Semibold:12.0"; else icol=0xffbac2de; lfont="SF Pro:Regular:12.0"; fi
    if printf '%s\n' "$saved" | grep -qxF "$ssid" || [ "$secure" = "0" ]; then
      q=$(printf '%q' "$ssid")
      cs="sketchybar --set wifi label='Menyambung...' popup.drawing=off; networksetup -setairportnetwork $IF $q; sleep 2; sketchybar --trigger wifi_change"
    else
      cs="sketchybar --set wifi popup.drawing=off; open 'x-apple.systempreferences:com.apple.wifi-settings-extension'"
    fi
    args+=(--set "wifi.p.$i" drawing=on icon="$sig" icon.color=$icol label="$ssid$lock" label.font="$lfont" click_script="$cs")
    i=$((i+1)); [ $i -ge 10 ] && break
  done < <(cat "$SCAN" 2>/dev/null)
  while [ $i -lt 10 ]; do args+=(--set "wifi.p.$i" drawing=off); i=$((i+1)); done
  sketchybar "${args[@]}" --set wifi popup.drawing=on
}

is_open() { [ "$(sketchybar --query wifi | /usr/bin/jq -r .popup.drawing)" = "on" ]; }

echo "$(date +%T.%N | cut -c1-12) $SENDER $NAME" >> /tmp/sketchybar_wifi_events.log

pin_young() { [ -e "$D/pin" ] && [ $(( $(date +%s) - $(stat -f %m "$D/pin") )) -lt 2 ]; }
close_later() { ( sleep 0.35; while pin_young; do sleep 0.3; done
  [ -z "$(ls -A "$D" | grep -v '^pin$')" ] && { rm -f "$D/pin"; sketchybar --set wifi popup.drawing=off; } ) & }

case "$SENDER" in
  mouse.entered)
    touch "$D/$NAME" ;;   # hover never opens the popup; click does
  mouse.exited)
    rm -f "$D/$NAME"; close_later ;;
  mouse.exited.global)
    # ignore the spurious global-exit that can follow a click
    if pin_young; then close_later; exit 0; fi
    rm -f "$D"/*; sketchybar --set wifi popup.drawing=off ;;
  mouse.clicked)
    if [ "$NAME" = "wifi" ]; then
      if is_open; then rm -f "$D/pin"; sketchybar --set wifi popup.drawing=off
      else touch "$D/pin" "$D/wifi"; build; rescan; fi
    fi ;;
  rescan_done)
    is_open && build ;;
esac
