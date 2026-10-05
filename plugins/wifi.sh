#!/bin/bash
case "$SENDER" in mouse.entered|mouse.exited|mouse.exited.global|mouse.clicked) exec "$CONFIG_DIR/plugins/wifi_popup.sh" ;; esac
# Wi-Fi status + SSID.
# macOS Sonoma/Sequoia+ redact the SSID for unprivileged processes
# ("<redacted>"). Order of attempts:
#   1. ipconfig getsummary <if>   (unredacted after: sudo ipconfig setverbose 1)
#   2. networksetup -getairportnetwork <if>  (works on older macOS)
#   3. fall back to "Connected" if the interface has an IP address.

# shellcheck source=../colors.sh
source "$CONFIG_DIR/colors.sh"
# shellcheck source=../icons.sh
source "$CONFIG_DIR/icons.sh"

# Find the Wi-Fi interface (en0 on every Apple Silicon MacBook, but be safe)
iface="$(networksetup -listallhardwareports 2>/dev/null \
          | awk '/Hardware Port: (Wi-Fi|AirPort)/ {getline; print $2; exit}')"
iface="${iface:-en0}"

is_valid() { [ -n "$1" ] && [ "$1" != "<redacted>" ]; }

ssid="$(ipconfig getsummary "$iface" 2>/dev/null \
         | awk -F ' SSID : ' '/ SSID : / {print $2; exit}')"

if ! is_valid "$ssid"; then
  ssid="$(networksetup -getairportnetwork "$iface" 2>/dev/null \
           | sed -nE 's/^Current Wi-Fi Network: (.*)$/\1/p')"
fi

ip="$(ipconfig getifaddr "$iface" 2>/dev/null)"

if is_valid "$ssid"; then
  sketchybar --set "$NAME" icon="$WIFI_CONNECTED" icon.color="$BLUE" label="$ssid"
elif [ -n "$ip" ]; then
  sketchybar --set "$NAME" icon="$WIFI_CONNECTED" icon.color="$BLUE" label="Connected"
else
  sketchybar --set "$NAME" icon="$WIFI_DISCONNECTED" icon.color="$RED" label="Offline"
fi
