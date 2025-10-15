#!/usr/bin/env sh

cliphist list | rofi -dmenu -i -config ~/.config/rofi/config-cliphist.rasi | cliphist decode | wl-copy && wtype -M ctrl -k v -m ctrl
