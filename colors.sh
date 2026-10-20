#!/bin/bash
# shellcheck disable=SC2034  # variables are used by files that source this one
# Theme: Monochrome minimal (putih / abu-abu / gelap transparan)
# Format: 0xAARRGGBB. Tema ungu lama: colors.sh.bak-purple / ~/.config/sketchybar.bak-mono-*

export BLACK=0xff111111
export WHITE=0xffe6e6e6
export GREY=0xff8a8a8a
export SUBTEXT=0xff9a9a9a
export TRANSPARENT=0x00000000
# Warna lama dipetakan ke monokrom (supaya plugin tetap jalan tanpa warna)
export RED=$WHITE        # status peringatan: putih terang
export ORANGE=$WHITE
export YELLOW=$WHITE
export GREEN=$WHITE
export BLUE=$WHITE
export TEAL=$WHITE
export PINK=$WHITE
export MAGENTA=$WHITE

# Bar & item backgrounds
export BAR_COLOR=0xb0101010
export BAR_BORDER_COLOR=0x00000000
export ITEM_BG_COLOR=0x00000000      # tanpa kotak di belakang item
export ITEM_BG_ACTIVE=0x22ffffff
export POPUP_BG_COLOR=0xf0161616
export POPUP_BORDER_COLOR=0xff2e2e2e

# Semantic colors
export ICON_COLOR=$WHITE
export LABEL_COLOR=$WHITE
export ACCENT_COLOR=0x26ffffff       # sorotan workspace aktif: putih tipis
