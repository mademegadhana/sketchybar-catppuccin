#!/bin/bash
# Compact Indonesian: date (grey, icon slot) + 24h time (white, label), e.g. "Sel 20 Okt  15.07"
D=(Min Sen Sel Rab Kam Jum Sab)
M=(Jan Feb Mar Apr Mei Jun Jul Agu Sep Okt Nov Des)
read -r w d m t <<<"$(date '+%w %d %m %H.%M')"
sketchybar --set "$NAME" icon="${D[$w]} $d ${M[$((10#$m-1))]} ·" label="$t"
