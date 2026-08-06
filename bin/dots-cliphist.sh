#!/usr/bin/env sh

cliphist list | skwig-dms-picker | cliphist decode | wl-copy && wtype -M ctrl -k v -m ctrl
