# sketchybar-catppuccin

Custom [SketchyBar](https://felixkratz.github.io/SketchyBar/) config for macOS on Apple Silicon, themed with Catppuccin Mocha and a darkened purple accent (`#5b4680`). Made for a MacBook Air M3 together with [AeroSpace](https://github.com/nikitabobko/AeroSpace) and [JankyBorders](https://github.com/FelixKratz/JankyBorders).

## Features

- Catppuccin Mocha colors with a dim purple accent
- AeroSpace workspaces that renumber themselves contiguously (1..N)
- Volume box with a hover slider and 1% scroll steps
- Wi-Fi click popup listing nearby networks by signal strength, with a small white lock on secured ones
- Calendar and battery click popups
- Memory and CPU temperature via [macmon](https://github.com/vladkens/macmon), refreshed after sleep/wake
- Apple menu with System Settings, Activity Monitor, Lock Screen, Sleep, Restart, Shut Down, and Log Out

## Layout

```
sketchybarrc            main bar definition
colors.sh               palette and accent
icons.sh                Nerd Font glyphs
helpers/icon_map.sh     app icon map
helpers/wifiscan/       Swift source for the SketchyWiFi scanner app
plugins/                item scripts
CARA-KEMBALIKAN.md      revert notes (Indonesian)
```

## Install

```bash
brew tap FelixKratz/formulae
brew install sketchybar macmon jq
brew install --cask font-hack-nerd-font

git clone https://github.com/mademegadhana/sketchybar-catppuccin.git ~/.config/sketchybar
chmod +x ~/.config/sketchybar/plugins/*.sh
brew services start sketchybar
```

Grant Accessibility to sketchybar when macOS asks. The Wi-Fi popup needs the small `SketchyWiFi` helper app (built from `helpers/wifiscan/main.swift`) with Location permission so it can see nearby network names.
