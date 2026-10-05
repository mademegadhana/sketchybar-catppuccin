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

current_ssid() {
  local s
  s="$(ipconfig getsummary $IF 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2; exit}')"
  [ -n "$s" ] && [ "$s" != "<redacted>" ] && { printf '%s' "$s"; return; }
  s="$(ipconfig getsummary $IF 2>/dev/null | awk '/^sname = / {sub(/^sname = /,""); print; exit}')"
  [ -n "$s" ] && { printf '%s' "$s"; return; }
  s="$(networksetup -getairportnetwork $IF 2>/dev/null | sed -nE 's/^Current Wi-Fi Network: (.*)$/\1/p')"
  [ -n "$s" ] && { printf '%s' "$s"; return; }
  [ -f /tmp/sketchybar_wifi_ssid ] && cat /tmp/sketchybar_wifi_ssid
}

same_net() {
  local a b
  a="$(printf '%s' "${1%.}" | tr '[:upper:]' '[:lower:]')"
  b="$(printf '%s' "${2%.}" | tr '[:upper:]' '[:lower:]')"
  [ "$a" = "$b" ]
}

build() {
  ensure_items
  # Open immediately so the first click always feels responsive.
  sketchybar --set wifi popup.drawing=on
  cur="$(current_ssid)"
  power="$(networksetup -getairportpower $IF | awk '{print $NF}')"
  saved="$(networksetup -listpreferredwirelessnetworks $IF 2>/dev/null | sed 's/^[[:space:]]*//' | awk 'NR>1 && NF')"
  if [ "$power" = "On" ]; then tlabel="Matikan Wi-Fi"; tcmd="Off"; else tlabel="Nyalakan Wi-Fi"; tcmd="On"; fi
  args=(--set wifi.p.toggle label="$tlabel"
        click_script="rm -f $D/sticky; networksetup -setairportpower $IF $tcmd; sketchybar --set wifi popup.drawing=off; sleep 3; sketchybar --trigger wifi_change")
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
  # Nearby only — same idea as macOS Wi-Fi menu (no offline saved networks).
  while IFS=$'\t' read -r ssid rssi secure; do
    [ -n "$ssid" ] || continue
    case "$ssid" in \#*) continue ;; esac
    if [ "$rssi" -ge -55 ]; then sig="󰤨"; elif [ "$rssi" -ge -67 ]; then sig="󰤥"; elif [ "$rssi" -ge -78 ]; then sig="󰤢"; else sig="󰤟"; fi
    lock=""; [ "$secure" = "1" ] && lock="  􀎡"
    if same_net "$ssid" "$cur"; then icol=0xffa6e3a1; lfont="SF Pro:Semibold:12.0"; else icol=0xffbac2de; lfont="SF Pro:Regular:12.0"; fi
    in_saved=0
    while IFS= read -r p; do same_net "$ssid" "$p" && { in_saved=1; break; }; done <<< "$saved"
    if [ $in_saved -eq 1 ] || [ "$secure" = "0" ]; then
      q=$(printf '%q' "$ssid")
      cs="rm -f $D/sticky; sketchybar --set wifi label='Menyambung...' popup.drawing=off; networksetup -setairportnetwork $IF $q; sleep 2; sketchybar --trigger wifi_change"
    else
      cs="rm -f $D/sticky; sketchybar --set wifi popup.drawing=off; open 'x-apple.systempreferences:com.apple.wifi-settings-extension'"
    fi
    args+=(--set "wifi.p.$i" drawing=on icon="$sig" icon.color=$icol label="$ssid$lock" label.font="$lfont" click_script="$cs")
    i=$((i+1)); [ $i -ge 10 ] && break
  done < <(awk -F'\t' 'NF>=2 && $1 !~ /^#/ {print}' "$SCAN" 2>/dev/null)
  while [ $i -lt 10 ]; do args+=(--set "wifi.p.$i" drawing=off); i=$((i+1)); done
  # Keep settings row click clearing sticky too
  args+=(--set wifi.p.settings
         click_script="rm -f $D/sticky; open 'x-apple.systempreferences:com.apple.wifi-settings-extension'; sketchybar --set wifi popup.drawing=off")
  sketchybar "${args[@]}" --set wifi popup.drawing=on
}

is_open() { [ "$(sketchybar --query wifi | /usr/bin/jq -r .popup.drawing)" = "on" ]; }

echo "$(date +%T.%N | cut -c1-12) $SENDER $NAME" >> /tmp/sketchybar_wifi_events.log

close_popup() {
  rm -f "$D"/*
  sketchybar --set wifi popup.drawing=off
}

case "$SENDER" in
  mouse.entered)
    touch "$D/$NAME" ;;
  mouse.exited)
    rm -f "$D/$NAME"
    # Click-opened popups stay until click-outside or second click.
    [ -e "$D/sticky" ] && exit 0
    ( sleep 0.35; [ -z "$(ls -A "$D" 2>/dev/null)" ] && sketchybar --set wifi popup.drawing=off ) & ;;
  mouse.exited.global)
    # Click-opened (sticky) popups ignore global-exit: it fires spuriously on
    # open and made the menu need several clicks. Close via second click or
    # by choosing a row instead.
    [ -e "$D/sticky" ] && exit 0
    close_popup ;;
  mouse.clicked)
    if [ "$NAME" = "wifi" ]; then
      if [ -e "$D/sticky" ] && is_open; then
        close_popup
      else
        mkdir -p "$D"
        touch "$D/sticky" "$D/wifi"
        date +%s > "$D/opened_at"
        build
        rescan
      fi
    fi ;;
  rescan_done)
    is_open && build ;;
esac
