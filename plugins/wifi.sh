#!/bin/bash
case "$SENDER" in mouse.entered|mouse.exited|mouse.exited.global|mouse.clicked) exec "$CONFIG_DIR/plugins/wifi_popup.sh" ;; esac
# Wi-Fi status + SSID.
# Personal Hotspot often fails networksetup ("not associated") and may
# redact the SSID; fall back through several sources and a small cache.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

CACHE=/tmp/sketchybar_wifi_ssid
iface="$(networksetup -listallhardwareports 2>/dev/null \
          | awk '/Hardware Port: (Wi-Fi|AirPort)/ {getline; print $2; exit}')"
iface="${iface:-en0}"

# 0) Wi-Fi radio powered off -> show off state (skip SSID/cache lookup)
if networksetup -getairportpower "$iface" 2>/dev/null | grep -q ': Off$'; then
  sketchybar --set "$NAME" icon="$WIFI_DISCONNECTED" icon.color="$GREY" label="Off"
  exit 0
fi

is_valid() {
  [ -n "$1" ] && [ "$1" != "<redacted>" ] && [ "$1" != "You are not associated with an AirPort network." ]
}

# 1) ipconfig SSID (works for many hotspots even when networksetup fails)
ssid="$(ipconfig getsummary "$iface" 2>/dev/null \
         | awk -F ' SSID : ' '/ SSID : / {print $2; exit}')"

# 2) DHCP sname (iPhone Personal Hotspot often puts the phone name here)
if ! is_valid "$ssid"; then
  ssid="$(ipconfig getsummary "$iface" 2>/dev/null \
           | awk '/^sname = / {sub(/^sname = /,""); print; exit}')"
fi

# 3) classic networksetup (regular Wi-Fi)
if ! is_valid "$ssid"; then
  ssid="$(networksetup -getairportnetwork "$iface" 2>/dev/null \
           | sed -nE 's/^Current Wi-Fi Network: (.*)$/\1/p')"
fi

# 4) strongest nearby match from last scan when on 172.20.10.x (hotspot range)
ip="$(ipconfig getifaddr "$iface" 2>/dev/null)"
if ! is_valid "$ssid" && [[ "$ip" == 172.20.10.* ]]; then
  ssid="$(awk -F'\t' 'NF>=2 && $1 !~ /^#/ {print $1; exit}' /tmp/sketchybar_wifi_scan.txt 2>/dev/null)"
fi

# 5) last known good name
if ! is_valid "$ssid" && [ -f "$CACHE" ]; then
  ssid="$(cat "$CACHE")"
fi

if is_valid "$ssid"; then
  # Prefer the preferred-network spelling (often "emdee." with a trailing dot)
  pref="$(networksetup -listpreferredwirelessnetworks "$iface" 2>/dev/null \
            | sed 's/^[[:space:]]*//' \
            | awk -v s="$ssid" 'BEGIN{l=tolower(s)} tolower($0)==l || tolower($0)==l"." || tolower($0)==substr(l,1,length(l)-1) {print; exit}')"
  [ -n "$pref" ] && ssid="$pref"
  printf '%s' "$ssid" > "$CACHE"
  sketchybar --set "$NAME" icon="$WIFI_CONNECTED" icon.color="$BLUE" label="$ssid"
elif [ -n "$ip" ]; then
  sketchybar --set "$NAME" icon="$WIFI_CONNECTED" icon.color="$BLUE" label="Hotspot"
else
  rm -f "$CACHE"
  sketchybar --set "$NAME" icon="$WIFI_DISCONNECTED" icon.color="$RED" label="Offline"
fi
