#!/bin/bash
# Now playing for Spotify / Apple Music via their distributed notifications
# (robust: does not depend on the private MediaRemote framework, which
# broke the built-in media_change event on macOS 15.4+ / 26).
# media_change is still handled for older macOS versions.

# shellcheck source=../icons.sh
source "$CONFIG_DIR/icons.sh"

# Extract a string value from flat JSON: json_get '<json>' 'Key Name'
json_get() {
  printf '%s' "$1" | sed -nE "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"(([^\"\\\\]|\\\\.)*)\".*/\\1/p" | head -n1 | sed -E 's/\\(.)/\1/g'
}

case "$SENDER" in
  mouse.clicked)
    if pgrep -xq Spotify; then
      osascript -e 'tell application "Spotify" to playpause'
    elif pgrep -xq Music; then
      osascript -e 'tell application "Music" to playpause'
    fi
    exit 0 ;;
  spotify_change|music_change)
    state="$(json_get "$INFO" 'Player State')"
    title="$(json_get "$INFO" 'Name')"
    artist="$(json_get "$INFO" 'Artist')"
    if [ "$SENDER" = "spotify_change" ]; then app_icon="$SPOTIFY"; else app_icon="$MUSIC"; fi ;;
  media_change)
    state="$(json_get "$INFO" 'state')"
    title="$(json_get "$INFO" 'title')"
    artist="$(json_get "$INFO" 'artist')"
    app_icon="$MUSIC" ;;
  *)
    exit 0 ;;
esac

case "$state" in
  Playing|playing)
    label="$title"
    [ -n "$artist" ] && label="$artist — $title"
    sketchybar --set "$NAME" drawing=on icon="$app_icon" label="$label" ;;
  *)
    sketchybar --set "$NAME" drawing=off ;;
esac
