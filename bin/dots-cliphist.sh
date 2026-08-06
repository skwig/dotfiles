#!/usr/bin/env sh

hist=$(skwig-dms-cliphist-picker) || exit
printf '%s\n' "$hist" | cliphist decode | wl-copy && wtype -M ctrl -k v -m ctrl
