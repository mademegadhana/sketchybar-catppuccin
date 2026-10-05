#!/bin/bash
# shellcheck disable=SC2034  # variables are used by files that source this one
# Theme: Catppuccin Mocha  (https://catppuccin.com/palette)
# Format: 0xAARRGGBB  (AA = alpha/opacity, ff = opaque, 00 = transparent)
# To change theme, just edit the hex values below and run: sketchybar --reload

export BLACK=0xff11111b     # crust
export WHITE=0xffcdd6f4     # text
export RED=0xfff38ba8
export GREEN=0xffa6e3a1
export BLUE=0xff89b4fa
export YELLOW=0xfff9e2af
export ORANGE=0xfffab387    # peach
export MAGENTA=0xffcba6f7   # mauve
export PINK=0xfff5c2e7
export TEAL=0xff94e2d5
export GREY=0xff7f849c      # overlay1
export SUBTEXT=0xffa6adc8   # subtext0
export TRANSPARENT=0x00000000

# Bar & item backgrounds
export BAR_COLOR=0xcc1e1e2e        # base, ~80% opacity (translucent)
export BAR_BORDER_COLOR=0xff313244 # surface0
export ITEM_BG_COLOR=0xff313244    # surface0
export ITEM_BG_ACTIVE=0xff45475a   # surface1
export POPUP_BG_COLOR=0xf01e1e2e
export POPUP_BORDER_COLOR=0xff585b70

# Semantic colors
export ICON_COLOR=$WHITE
export LABEL_COLOR=$WHITE
export ACCENT_COLOR=0xff5b4680   # darker mauve
